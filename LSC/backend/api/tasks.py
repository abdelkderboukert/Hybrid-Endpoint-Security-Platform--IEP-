from django.conf import settings
from django.urls import reverse
from django.utils import timezone
from django.db import transaction, models
import requests
import logging
import uuid
import os
from pathlib import Path
from dotenv import set_key, load_dotenv
import json

# Import models and serializers for local processing
from .models import SyncLog, Admin, User, Device, Server, Group, LicenseKey
from .serializers import SERIALIZER_MAP, MODEL_MAP
from .util import SystemDetector

logger = logging.getLogger(__name__)

# --- DEFINE THE PATH TO THE .env FILE CONSISTENTLY ---
APP_NAME = "Bluck D-ESC"
FOLDER_NAME = f"{APP_NAME}_env"
system_drive = os.environ.get('SystemDrive', 'C:')
ENV_FILE_PATH = Path(f"{system_drive}\\") / FOLDER_NAME / '.env'

# --- Custom JSON Encoder just for this script ---
class UUIDEncoder(json.JSONEncoder):
    """ Custom JSON encoder to handle UUIDs. """
    def default(self, obj):
        if isinstance(obj, uuid.UUID):
            return str(obj)
        return super().default(obj)

def save_to_env(key_to_set: str, value_to_set: str):
    """Saves a key-value pair to the central .env file."""
    try:
        if not ENV_FILE_PATH.is_file():
            ENV_FILE_PATH.touch()
        set_key(dotenv_path=ENV_FILE_PATH, key_to_set=key_to_set, value_to_set=value_to_set)
        logger.info(f"Successfully saved {key_to_set} to {ENV_FILE_PATH}")
        return True
    except Exception as e:
        logger.error(f"FATAL: Failed to save to .env file: {e}")
        return False

def collect_local_changes(last_sync_timestamp):
    """
    Queries the local database for all changes since the last sync.
    """
    sync_items_up = []
    if not last_sync_timestamp:
        logger.info("First sync, no local changes to send up.")
        return sync_items_up
        
    try:
        last_sync_dt = timezone.datetime.fromisoformat(last_sync_timestamp)
    except (ValueError, TypeError):
        logger.error(f"Invalid last_sync_timestamp format: {last_sync_timestamp}")
        return []

    for model_name, Model in MODEL_MAP.items():
        if not hasattr(Model, 'last_modified'):
            continue
        
        queryset = Model.objects.filter(last_modified__gt=last_sync_dt)
        serializer_class = SERIALIZER_MAP.get(model_name)
        if not serializer_class:
            continue

        for instance in queryset:
            serializer = serializer_class(instance)
            action = 'delete' if getattr(instance, 'is_deleted', False) else 'update'
            
            clean_data_str = json.dumps(serializer.data, cls=UUIDEncoder)
            clean_data = json.loads(clean_data_str)
            
            sync_items_up.append({
                'model_name': model_name,
                'action': action,
                'data': clean_data,
                'client_last_modified': instance.last_modified.isoformat(),
            })
    
    logger.info(f"Collected {len(sync_items_up)} local items to sync up.")
    return sync_items_up

# api/tasks.py

def apply_parent_changes(sync_down_items):
    """
    Processes and applies changes received from the parent server,
    correctly handling ForeignKey and ManyToManyField relationships using a two-pass approach.
    """
    order = ['LicenseKey', 'Admin', 'Group', 'Server', 'User', 'Device']
    sync_down_items.sort(key=lambda item: order.index(item['model_name']) if item['model_name'
] in order else len(order))
    
    parent_server_id_str = os.getenv('PARENT_SERVER_ID')
    parent_server_id = uuid.UUID(parent_server_id_str) if parent_server_id_str else None
    
    deferred_updates = []

    with transaction.atomic():
        # --- FIRST PASS: Create/update objects without complex FKs ---
        for item in sync_down_items:
            model_name = item.get('model_name')
            action = item.get('action')
            data = item.get('data')
            
            Model = MODEL_MAP.get(model_name)
            if not Model:
                logger.warning(f"Skipping sync down for unknown model: {model_name}")
                continue
            
            pk_field_name = Model._meta.pk.name
            record_id = data.get(pk_field_name)

            if not record_id:
                logger.error(f"Skipping item for model {model_name} due to missing PK in data: {data}")
                continue

            try:
                if action in ['create', 'update']:
                    defaults_data = data.copy()
                    m2m_data = {}
                    
                    deferred_fields = {}
                    deferred_keys = ['parent_admin_id', 'parent_server']
                    if model_name == 'Admin':
                        deferred_keys.append('server')

                    for key in deferred_keys:
                        if key in defaults_data and defaults_data[key] is not None:
                            deferred_fields[key] = defaults_data.pop(key)

                    if deferred_fields:
                        deferred_updates.append({
                            'model': Model,
                            'pk': record_id,
                            'fields_to_update': deferred_fields
                        })

                    if pk_field_name in defaults_data:
                        del defaults_data[pk_field_name]
                    
                    for field in Model._meta.get_fields():
                        if isinstance(field, models.ForeignKey) and field.name in defaults_data:
                            fk_value = defaults_data.pop(field.name)
                            if fk_value:
                                defaults_data[f"{field.name}_id"] = fk_value
                        
                        if isinstance(field, models.ManyToManyField) and field.name in defaults_data:
                            m2m_data[field.name] = defaults_data.pop(field.name)

                    instance, created = Model.objects.update_or_create(
                        pk=record_id,
                        defaults=defaults_data
                    )

                    if parent_server_id:
                        instance.source_device_id = parent_server_id
                        instance.save(update_fields=['source_device_id'])

                    logger.info(f"Successfully {'created' if created else 'updated'} {model_name} record {record_id} (Pass 1).")

                    if m2m_data:
                        for field_name, value in m2m_data.items():
                            manager = getattr(instance, field_name)
                            manager.set(value)
                            logger.info(f"Successfully set M2M relation '{field_name}' for {model_name} {record_id}.")
                
                # <-- BUG FIX: Moved delete action inside the try block -->
                elif action == 'delete':
                    Model.objects.filter(pk=record_id).update(is_deleted=True)
                    logger.info(f"Successfully marked {model_name} record {record_id} as deleted.")

            except Exception as e:
                logger.error(f"Failed to apply sync down for {model_name} record {record_id} in Pass 1. Data: {data}. Error: {e}")
                raise
        
        # --- SECOND PASS: Apply the deferred relationships ---
        logger.info(f"Starting Pass 2: Applying {len(deferred_updates)} deferred relationships.")
        for update_job in deferred_updates:
            try:
                Model = update_job['model']
                pk = update_job['pk']
                fields = update_job['fields_to_update']
                
                update_data = {f"{k}_id": v for k, v in fields.items()}
                
                # <-- NEW: Added diagnostic logging -->
                logger.info(f"Applying deferred update for {Model.__name__} {pk} with data: {update_data}")

                Model.objects.filter(pk=pk).update(**update_data)
                logger.info(f"Successfully applied parent links for {Model.__name__} {pk} (Pass 2).")
            except Exception as e:
                logger.error(f"Failed to apply deferred update for {update_job['model'].__name__} {update_job['pk']}. Data: {update_data}. Error: {e}")
                raise

def perform_standard_sync(api_key: str, parent_ip: str, last_sync: str):
    """
    Helper function to perform a standard, authenticated, bidirectional sync.
    """
    logger.info(f"Running standard sync. Last sync was at: {last_sync}")
    sync_url = f"http://{parent_ip}:8000{reverse('master-sync')}"
    
    try:
        print(last_sync)
        sync_items_to_send = collect_local_changes(last_sync)
        
        payload = {
            "sync_items": sync_items_to_send,
            "last_sync_timestamp": last_sync,
        }
        headers = {'Authorization': f'Bearer {api_key}', 'Content-Type': 'application/json'}
        
        response = requests.post(sync_url, json=payload, headers=headers, timeout=30)
        response.raise_for_status()
        
        response_data = response.json()
        sync_down_items = response_data.get('sync_down_items', [])
        new_timestamp = response_data.get('current_timestamp')

        logger.info(f"Received {len(sync_down_items)} items to sync down.")
        
        if sync_down_items:
            apply_parent_changes(sync_down_items)
            
        if new_timestamp:
            save_to_env('LAST_SUCCESSFUL_SYNC', new_timestamp)
        
        logger.info("Standard sync cycle completed successfully.")
        
    except requests.exceptions.RequestException as e:
        error_text = e.response.text if e.response else str(e)
        logger.error(f"Standard sync to {sync_url} failed. Error: {error_text}")
    except Exception as e:
        logger.error(f"An unexpected error occurred during standard sync: {e}")

def run_master_sync():
    """ The main task that orchestrates the registration or sync process. """
    load_dotenv(dotenv_path=ENV_FILE_PATH)
    
    permanent_api_key = os.getenv('LSC_API_KEY')
    parent_ip = os.getenv('INITIAL_PARENT_IP')
    
    if not parent_ip:
        logger.error("INITIAL_PARENT_IP is not set in .env. Cannot sync.")
        return

    if permanent_api_key:
        last_sync_timestamp = os.getenv('LAST_SUCCESSFUL_SYNC')
        print("last_sync_timestamp:")  
        print(last_sync_timestamp)
        perform_standard_sync(permanent_api_key, parent_ip, last_sync_timestamp)
    else:
        logger.info("No permanent API key found. Attempting initial server registration.")
        bootstrap_token = os.getenv('BOOTSTRAP_TOKEN')
        owner_admin_id = os.getenv('OWNER_ADMIN_ID')

        if not bootstrap_token or not owner_admin_id:
            logger.error("BOOTSTRAP_TOKEN or OWNER_ADMIN_ID not set in .env file. Cannot register server.")
            return

        try:
            detector = SystemDetector()
            server_data = detector.get_complete_system_info()

            for key, value in server_data.items():
                if isinstance(value, uuid.UUID): server_data[key] = str(value)
                if hasattr(value, 'isoformat'): server_data[key] = value.isoformat()
            
            payload = {
                "bootstrap_token": bootstrap_token, 
                "server_data": server_data,
                "owner_admin_id": owner_admin_id
            }
            register_url = f"http://{parent_ip}:8000{reverse('server-register')}"
            
            response = requests.post(register_url, json=payload, timeout=60)
            response.raise_for_status()
            response_data = response.json()
            new_api_key = response_data.get('api_key')
            
            if new_api_key:
                save_to_env("LSC_API_KEY", new_api_key)
                logger.info("Registration successful. Performing initial data sync immediately.")
                perform_standard_sync(new_api_key, parent_ip, None) 
            else:
                logger.error("Registration failed: Did not receive an API Key.")

        except requests.exceptions.RequestException as e:
            error_text = e.response.text if e.response else str(e)
            logger.error(f"Server registration request to {register_url} failed. Error: {error_text}")
        except Exception as e:
            logger.error(f"An unexpected error occurred during registration: {e}")