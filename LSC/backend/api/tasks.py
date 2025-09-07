# from celery import shared_task
# from django.conf import settings
# from django.urls import reverse
# import requests
# import logging
# import uuid
# from dotenv import set_key

# from .models import Admin, Server, SyncLog
# from .util import SystemDetector

# logger = logging.getLogger(__name__)

# def save_api_key_to_env(api_key: str):
#     """Saves the retrieved API key to the .env file."""
#     try:
#         env_path = settings.ENV_PATH
#         if not env_path.is_file():
#             env_path.touch()
        
#         set_key(dotenv_path=env_path, key_to_set="LSC_API_KEY", value_to_set=api_key)
#         logger.info(f"Successfully saved new API key to {env_path}")
#         return True
#     except Exception as e:
#         logger.error(f"FATAL: Failed to save API key to .env file: {e}")
#         return False

# @shared_task
# def run_master_sync():
#     permanent_api_key = getattr(settings, 'LSC_API_KEY', None)
#     parent_ip = getattr(settings, 'INITIAL_PARENT_IP', None)

#     if not parent_ip:
#         logger.error("INITIAL_PARENT_IP is not set in .env. Cannot sync.")
#         return

#     if permanent_api_key:
#         # --- SCENARIO A: ONGOING SYNC ---
#         logger.info("Permanent API key found. Running standard sync.")
#         sync_url = f"http://{parent_ip}:8000{reverse('master-sync')}"
        
#         try:
#             # We don't need to look up the server locally for the sync payload.
#             # The parent will identify us by the API key.
#             # We only need the last sync time.
#             last_sync_log = SyncLog.objects.order_by('-timestamp').first()
            
#             payload = {
#                 "sync_items": [],
#                 "last_sync_timestamp": last_sync_log.timestamp.isoformat() if last_sync_log else None,
#             }
#             headers = {'Authorization': f'Bearer {permanent_api_key}', 'Content-Type': 'application/json'}
            
#             response = requests.post(sync_url, json=payload, headers=headers, timeout=30)
#             response.raise_for_status()
#             logger.info("Standard sync successful.")
            
#             # TODO: Add logic to process the sync_down_items from response.json()
            
#         except requests.exceptions.RequestException as e:
#             logger.error(f"Standard sync to {sync_url} failed. Error: {e.response.text if e.response else e}")
#         except Exception as e:
#             logger.error(f"An unexpected error occurred during standard sync: {e}")

#     else:
#         # --- SCENARIO B: FIRST RUN - REGISTRATION ---
#         logger.info("No permanent API key found. Attempting initial server registration.")
#         bootstrap_token = getattr(settings, 'BOOTSTRAP_TOKEN', None)
#         if not bootstrap_token:
#             logger.error("BOOTSTRAP_TOKEN not set in .env file. Cannot register server.")
#             return

#         try:
#             detector = SystemDetector()
#             server_data = detector.get_complete_system_info()

#             # Clean data for JSON serialization
#             for key, value in server_data.items():
#                 if isinstance(value, (uuid.UUID,)):
#                     server_data[key] = str(value)
#                 if hasattr(value, 'isoformat'): # Handles datetime
#                     server_data[key] = value.isoformat()
            
#             payload = {
#                 "bootstrap_token": bootstrap_token,
#                 "server_data": server_data
#             }
#             register_url = f"http://{parent_ip}:8000{reverse('server-register')}"
            
#             response = requests.post(register_url, json=payload, timeout=60)
#             response.raise_for_status()

#             response_data = response.json()
#             new_api_key = response_data.get('api_key')
            
#             if new_api_key:
#                 if save_api_key_to_env(new_api_key):
#                     logger.info("Registration successful. API key saved. The next run will be a standard sync.")
#                 else:
#                     logger.error("Registration succeeded but could not save the API Key. The LSC will re-register on next run.")
#             else:
#                 logger.error("Registration response did not include an API key.")

#         except requests.exceptions.RequestException as e:
#             logger.error(f"Server registration request to {register_url} failed. Error: {e.response.text if e.response else e}")
#         except Exception as e:
#             logger.error(f"An unexpected error occurred during registration: {e}")


from celery import shared_task
from django.conf import settings
from django.urls import reverse
import requests
import logging
import uuid
from dotenv import set_key, load_dotenv
import os
from pathlib import Path

from .models import SyncLog
from .util import SystemDetector

logger = logging.getLogger(__name__)

# --- DEFINE THE PATH TO THE .env FILE CONSISTENTLY ---
APP_NAME = "Bluck D-ESC"
FOLDER_NAME = f"{APP_NAME}_env"
system_drive = os.environ.get('SystemDrive', 'C:')
ENV_FILE_PATH = Path(f"{system_drive}\\") / FOLDER_NAME / '.env'


def save_api_key_to_env(api_key: str):
    """Saves the retrieved API key to the central .env file."""
    try:
        if not ENV_FILE_PATH.is_file():
            ENV_FILE_PATH.touch()
        set_key(dotenv_path=ENV_FILE_PATH, key_to_set="LSC_API_KEY", value_to_set=api_key)
        logger.info(f"Successfully saved new API key to {ENV_FILE_PATH}")
        return True
    except Exception as e:
        logger.error(f"FATAL: Failed to save API key to .env file: {e}")
        return False

def perform_standard_sync(api_key: str, parent_ip: str):
    """Helper function to perform a standard, authenticated sync."""
    logger.info("Permanent API key found. Running standard sync.")
    sync_url = f"http://{parent_ip}:8000{reverse('master-sync')}"
    
    try:
        last_sync_log = SyncLog.objects.order_by('-timestamp').first()
        payload = {
            "sync_items": [],
            "last_sync_timestamp": last_sync_log.timestamp.isoformat() if last_sync_log else None,
        }
        headers = {'Authorization': f'Bearer {api_key}', 'Content-Type': 'application/json'}
        
        response = requests.post(sync_url, json=payload, headers=headers, timeout=30)
        response.raise_for_status()
        logger.info("Standard sync successful.")
        
    except requests.exceptions.RequestException as e:
        error_text = e.response.text if e.response else str(e)
        logger.error(f"Standard sync to {sync_url} failed. Error: {error_text}")
    except Exception as e:
        logger.error(f"An unexpected error occurred during standard sync: {e}")

@shared_task
def run_master_sync():
    # --- THIS IS THE CRUCIAL FIX ---
    # Manually load the .env file every time the task runs
    load_dotenv(dotenv_path=ENV_FILE_PATH)
    permanent_api_key = os.getenv('LSC_API_KEY')
    parent_ip = os.getenv('INITIAL_PARENT_IP')
    
    if not parent_ip:
        logger.error("INITIAL_PARENT_IP is not set in .env. Cannot sync.")
        return

    if permanent_api_key:
        perform_standard_sync(permanent_api_key, parent_ip)
    else:
        logger.info("No permanent API key found. Attempting initial server registration.")
        bootstrap_token = os.getenv('BOOTSTRAP_TOKEN')
        if not bootstrap_token:
            logger.error("BOOTSTRAP_TOKEN not set in .env file. Cannot register server.")
            return

        try:
            detector = SystemDetector()
            server_data = detector.get_complete_system_info()

            for key, value in server_data.items():
                if isinstance(value, uuid.UUID):
                    server_data[key] = str(value)
                if hasattr(value, 'isoformat'):
                    server_data[key] = value.isoformat()
            
            payload = {"bootstrap_token": bootstrap_token, "server_data": server_data}
            register_url = f"http://{parent_ip}:8000{reverse('server-register')}"
            
            response = requests.post(register_url, json=payload, timeout=60)
            response.raise_for_status()
            response_data = response.json()
            new_api_key = response_data.get('api_key')
            
            if new_api_key and save_api_key_to_env(new_api_key):
                logger.info("Registration successful. Performing initial data sync immediately.")
                perform_standard_sync(new_api_key, parent_ip)
            else:
                logger.error("Registration failed or could not save the API Key.")

        except requests.exceptions.RequestException as e:
            error_text = e.response.text if e.response else str(e)
            logger.error(f"Server registration request to {register_url} failed. Error: {error_text}")
        except Exception as e:
            logger.error(f"An unexpected error occurred during registration: {e}")