# from celery import shared_task
# from django.conf import settings
# from django.urls import reverse
# from rest_framework.test import APIClient
# from rest_framework_simplejwt.tokens import RefreshToken
# import json
# import logging
# from .models import Admin, Server, SyncLog
# from django.utils import timezone
# from datetime import timedelta
# from .util import get_parent_server_ip # <-- New import

# logger = logging.getLogger(__name__)

# @shared_task
# def run_master_sync():
#     """
#     A periodic task to run the MasterSyncAPIView for all active LSC admins.
#     """
#     try:
#         # Find all active LSC admins who own a server.
#         lsc_admins = Admin.objects.filter(is_active=True, layer__gt=0, server__isnull=False)

#         for admin in lsc_admins:
#             client = APIClient()

#             # --- DYNAMIC PARENT IP LOOKUP ---
#             if admin.server and admin.server.parent_server:
#                 parent_ip = get_parent_server_ip(admin.server.server_id)
#                 if not parent_ip:
#                     logger.warning(f"No parent IP found for admin {admin.username}. Skipping sync.")
#                     continue
                
#                 # Construct the full URL for the parent server's sync endpoint
#                 sync_url = f"http://{parent_ip}:8000{reverse('master-sync')}"
#             else:
#                 logger.warning(f"Admin {admin.username} is not attached to a server with a parent. Skipping sync.")
#                 continue

#             # Generate a JWT for the admin to authenticate the request
#             refresh = RefreshToken.for_user(admin)
#             client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

#             last_successful_sync_log = SyncLog.objects.filter(admin=admin).order_by('-timestamp').first()
#             last_sync_timestamp = last_successful_sync_log.timestamp.isoformat() if last_successful_sync_log else None

#             payload = {
#                 "sync_items": [],
#                 "last_sync_timestamp": last_sync_timestamp,
#                 "source_device_id": str(admin.server.server_id)
#             }

#             # Send the request to the MasterSyncAPIView
#             # NOTE: We are still using APIClient here as an internal test.
#             # For a real-world scenario, you would use a library like `requests`.
#             response = client.post(sync_url, payload, format='json')

#             if response.status_code == 200:
#                 logger.info(f"Master sync for admin {admin.username} to parent {parent_ip} successful.")
#             else:
#                 logger.error(f"Master sync for admin {admin.username} failed with status {response.status_code}: {response.content}")

#     except Exception as e:
#         logger.error(f"An unexpected error occurred during periodic sync: {e}")
####################################################################################################################################

# from celery import shared_task
# from django.conf import settings
# from django.urls import reverse
# from rest_framework.test import APIClient
# from rest_framework_simplejwt.tokens import RefreshToken
# import json
# import logging
# from .models import Admin, Server, SyncLog
# from django.utils import timezone
# from datetime import timedelta
# from .util import get_parent_server_ip # New import
# import requests # New import for external API calls

# logger = logging.getLogger(__name__)

# # Assume settings.py has a variable like this:
# # MCC_IP_ADDRESS = 'your_master_cloud_controller_ip'

# @shared_task
# def run_master_sync():
#     """
#     A periodic task to run the MasterSyncAPIView with a parent-to-MCC failover.
#     """
#     try:
#         lsc_admins = Admin.objects.filter(is_active=True, layer__gt=0, server__isnull=False)

#         for admin in lsc_admins:
#             sync_url = None
            
#             # --- PHASE 1: Try to Sync with Parent Server ---
#             if admin.server and admin.server.parent_server:
#                 parent_ip = get_parent_server_ip(admin.server.server_id)
#                 if parent_ip:
#                     sync_url = f"http://{parent_ip}:8000{reverse('master-sync')}"
#                     logger.info(f"Attempting sync for admin {admin.username} with parent at {parent_ip}...")
#                 else:
#                     logger.warning(f"No parent IP found for admin {admin.username}. Falling back to MCC.")
#             else:
#                 logger.warning(f"Admin {admin.username} is not attached to a server with a parent. Falling back to MCC.")

#             # --- PHASE 2: Fallback to Master Cloud Controller (MCC) ---
#             if not sync_url:
#                 if hasattr(settings, 'MCC_IP_ADDRESS'):
#                     sync_url = f"http://{settings.MCC_IP_ADDRESS}:8000{reverse('master-sync')}"
#                     logger.info(f"Attempting sync for admin {admin.username} with MCC at {settings.MCC_IP_ADDRESS}...")
#                 else:
#                     logger.error("MCC IP address is not configured. Skipping sync.")
#                     continue

#             # Build the request payload
#             last_successful_sync_log = SyncLog.objects.filter(admin=admin).order_by('-timestamp').first()
#             last_sync_timestamp = last_successful_sync_log.timestamp.isoformat() if last_successful_sync_log else None

#             payload = {
#                 "sync_items": [],
#                 "last_sync_timestamp": last_sync_timestamp,
#                 "source_device_id": str(admin.server.server_id)
#             }

#             try:
#                 # Use a real HTTP client to make the external request
#                 response = requests.post(sync_url, json=payload, timeout=30)
#                 response.raise_for_status() # Raise an exception for bad status codes

#                 logger.info(f"Sync for admin {admin.username} to {sync_url} successful.")
#                 # You can process the response data here if needed
                
#             except requests.exceptions.RequestException as e:
#                 logger.error(f"Sync failed for admin {admin.username} to {sync_url}. Error: {e}")
#                 # You could add logic here to trigger the fallback from parent to MCC
#                 # but with the current design, we've already done that with our initial if/else.

#     except Exception as e:
#         logger.error(f"An unexpected error occurred during periodic sync: {e}")

#####################################################################################################################################
# from celery import shared_task
# from django.conf import settings
# from django.urls import reverse
# import requests
# import logging
# import uuid
# import time
# from .models import Admin, Server, SyncLog
# from django.utils import timezone
# from .util import SystemDetector

# logger = logging.getLogger(__name__)

# # Assumed settings.py variables:
# # LSC_MAC_ADDRESS = 'your_lsc_mac_address_here'
# # PARENT_SERVER_ID = 'the_parent_server_uuid_from_the_cloud'
# # INITIAL_PARENT_IP = '192.168.1.10'
# # MCC_IP_ADDRESS = 'your_master_cloud_controller_ip'

# @shared_task
# def run_master_sync():
#     sync_url = None
#     payload = {
#         "sync_items": [],
#         "last_sync_timestamp": None,
#         "source_device_id": None
#     }

#     try:
#         # --- ONGOING SYNC (Subsequent Runs) ---
#         # Try to get the current server record. This will succeed on all runs after the first.
#         current_server = Server.objects.get(mac_address=settings.LSC_MAC_ADDRESS)
#         admin = Admin.objects.get(server=current_server)
        
#         # Build payload with current server and admin info
#         payload["source_device_id"] = str(current_server.server_id)
#         last_sync_log = SyncLog.objects.filter(admin=admin).order_by('-timestamp').first()
#         if last_sync_log:
#             payload["last_sync_timestamp"] = last_sync_log.timestamp.isoformat()

#         # Get parent IP from the local database
#         if current_server.parent_server:
#             parent_ip = current_server.parent_server.ip_address
#             if parent_ip:
#                 sync_url = f"http://{parent_ip}:8000{reverse('master-sync')}"
#                 logger.info(f"Using database-driven sync for admin {admin.username} to parent {parent_ip}...")
#             else:
#                 logger.warning("Parent server record found but no IP address. Falling back to initial connection IP.")
#         else:
#             logger.warning("Parent server not linked to current record. Falling back to initial connection IP.")
            
#     except Server.DoesNotExist:
#         # --- INITIAL SYNC (First Run) ---
#         # The server record doesn't exist yet, so this is our first run.
#         logger.info("Local server record not found. This is the first run. Using static IP to bootstrap.")
        
#         # Payload for initial sync doesn't include an existing source device ID
#         payload["source_device_id"] = str(uuid.uuid4()) # Use a placeholder
        
#     except Exception as e:
#         logger.error(f"An unexpected error occurred during server lookup: {e}")
#         return # Cannot proceed without finding the current server record

#     # --- Initial Connection and Failover Logic ---
#     if not sync_url and hasattr(settings, 'INITIAL_PARENT_IP'):
#         sync_url = f"http://{settings.INITIAL_PARENT_IP}:8000{reverse('master-sync')}"
#         logger.info(f"Attempting initial or failover sync to {settings.INITIAL_PARENT_IP}...")
    
#     if not sync_url and hasattr(settings, 'MCC_IP_ADDRESS'):
#         sync_url = f"http://{settings.MCC_IP_ADDRESS}:8000{reverse('master-sync')}"
#         logger.info(f"Initial connection failed. Falling back to MCC at {settings.MCC_IP_ADDRESS}...")
    
#     if not sync_url:
#         logger.error("No valid sync URL could be determined. Skipping sync.")
#         return

#     # Now make the actual sync request
#     try:
#         response = requests.post(sync_url, json=payload, timeout=30)
#         response.raise_for_status()

#         logger.info(f"Sync to {sync_url} successful.")

#         # --- AFTER SYNC: CREATE AND LINK LOCAL SERVER RECORD ---
#         if 'current_server' not in locals():
#             logger.info("Sync successful. Creating local server record and linking parent.")
#             detector = SystemDetector()
#             server_data = detector.get_complete_system_info()
            
#             parent_server = Server.objects.get(server_id=uuid.UUID(settings.PARENT_SERVER_ID))
            
#             # The local record is created with the parent link
#             Server.objects.create(
#                 parent_server=parent_server,
#                 mac_address=settings.LSC_MAC_ADDRESS,
#                 **server_data
#             )
#             logger.info("Local server record created successfully. Next sync will use local database lookup.")

#     except requests.exceptions.RequestException as e:
#         logger.error(f"Sync failed to {sync_url}. Error: {e}")
#     except Server.DoesNotExist:
#         logger.error("Parent server record not found in synced data. Cannot link server.")
#     except Exception as e:
#         logger.error(f"An unexpected error occurred: {e}")

###############################################################################################################
from celery import shared_task
from django.conf import settings
from django.urls import reverse
import requests
import logging
import uuid
import time
from .models import Admin, Server, SyncLog
from django.utils import timezone
from .util import SystemDetector

logger = logging.getLogger(__name__)

# Assumed settings.py variables:
# PARENT_SERVER_ID = 'the_parent_server_uuid_from_the_cloud'
# INITIAL_PARENT_IP = '192.168.1.10'
# MCC_IP_ADDRESS = 'your_master_cloud_controller_ip'

@shared_task
def run_master_sync():
    sync_url = None
    payload = {
        "sync_items": [],
        "last_sync_timestamp": None,
        "source_device_id": None
    }
    
    # --- STEP 1: Get the current machine's system UUID directly ---
    detector = SystemDetector()
    current_system_uuid = detector.get_system_uuid()
    if not current_system_uuid:
        logger.error("Could not get a system UUID. Cannot proceed with sync.")
        return

    try:
        # --- ONGOING SYNC (Subsequent Runs) ---
        # Find the current server record by its system UUID
        current_server = Server.objects.get(system_uuid=current_system_uuid)
        admin = Admin.objects.get(server=current_server)
        
        payload["source_device_id"] = str(current_server.server_id)
        last_sync_log = SyncLog.objects.filter(admin=admin).order_by('-timestamp').first()
        if last_sync_log:
            payload["last_sync_timestamp"] = last_sync_log.timestamp.isoformat()

        if current_server.parent_server:
            parent_ip = current_server.parent_server.ip_address
            if parent_ip:
                sync_url = f"http://{parent_ip}:8000{reverse('master-sync')}"
                logger.info(f"Using database-driven sync for admin {admin.username} to parent {parent_ip}...")
            else:
                logger.warning("Parent server record found but no IP address. Falling back to initial connection IP.")
        else:
            logger.warning("Parent server not linked to current record. Falling back to initial connection IP.")
            
    except Server.DoesNotExist:
        # --- INITIAL SYNC (First Run) ---
        logger.info("Local server record not found. This is the first run. Using static IP to bootstrap.")
        
        payload["source_device_id"] = str(uuid.uuid4())
        
    except Exception as e:
        logger.error(f"An unexpected error occurred during server lookup: {e}")
        return

    # --- Initial Connection and Failover Logic ---
    if not sync_url and hasattr(settings, 'INITIAL_PARENT_IP'):
        sync_url = f"http://{settings.INITIAL_PARENT_IP}:8000{reverse('master-sync')}"
        logger.info(f"Attempting initial or failover sync to {settings.INITIAL_PARENT_IP}...")
    
    if not sync_url and hasattr(settings, 'MCC_IP_ADDRESS'):
        sync_url = f"http://{settings.MCC_IP_ADDRESS}:8000{reverse('master-sync')}"
        logger.info(f"Initial connection failed. Falling back to MCC at {settings.MCC_IP_ADDRESS}...")
    
    if not sync_url:
        logger.error("No valid sync URL could be determined. Skipping sync.")
        return

    # Now make the actual sync request
    try:
        response = requests.post(sync_url, json=payload, timeout=30)
        response.raise_for_status()

        logger.info(f"Sync to {sync_url} successful.")

        if 'current_server' not in locals():
            logger.info("Sync successful. Creating local server record and linking parent.")
            server_data = detector.get_complete_system_info()
            
            parent_server = Server.objects.get(server_id=uuid.UUID(settings.PARENT_SERVER_ID))
            
            Server.objects.create(
                parent_server=parent_server,
                system_uuid=current_system_uuid,
                **server_data
            )
            logger.info("Local server record created successfully. Next sync will use local database lookup.")

    except requests.exceptions.RequestException as e:
        logger.error(f"Sync failed to {sync_url}. Error: {e}")
    except Server.DoesNotExist:
        logger.error("Parent server record not found in synced data. Cannot link server.")
    except Exception as e:
        logger.error(f"An unexpected error occurred: {e}")