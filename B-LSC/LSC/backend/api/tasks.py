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


from celery import shared_task
from django.conf import settings
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken
import json
import logging
from .models import Admin, Server, SyncLog
from django.utils import timezone
from datetime import timedelta
from .util import get_parent_server_ip # New import
import requests # New import for external API calls

logger = logging.getLogger(__name__)

# Assume settings.py has a variable like this:
# MCC_IP_ADDRESS = 'your_master_cloud_controller_ip'

@shared_task
def run_master_sync():
    """
    A periodic task to run the MasterSyncAPIView with a parent-to-MCC failover.
    """
    try:
        lsc_admins = Admin.objects.filter(is_active=True, layer__gt=0, server__isnull=False)

        for admin in lsc_admins:
            sync_url = None
            
            # --- PHASE 1: Try to Sync with Parent Server ---
            if admin.server and admin.server.parent_server:
                parent_ip = get_parent_server_ip(admin.server.server_id)
                if parent_ip:
                    sync_url = f"http://{parent_ip}:8000{reverse('master-sync')}"
                    logger.info(f"Attempting sync for admin {admin.username} with parent at {parent_ip}...")
                else:
                    logger.warning(f"No parent IP found for admin {admin.username}. Falling back to MCC.")
            else:
                logger.warning(f"Admin {admin.username} is not attached to a server with a parent. Falling back to MCC.")

            # --- PHASE 2: Fallback to Master Cloud Controller (MCC) ---
            if not sync_url:
                if hasattr(settings, 'MCC_IP_ADDRESS'):
                    sync_url = f"http://{settings.MCC_IP_ADDRESS}:8000{reverse('master-sync')}"
                    logger.info(f"Attempting sync for admin {admin.username} with MCC at {settings.MCC_IP_ADDRESS}...")
                else:
                    logger.error("MCC IP address is not configured. Skipping sync.")
                    continue

            # Build the request payload
            last_successful_sync_log = SyncLog.objects.filter(admin=admin).order_by('-timestamp').first()
            last_sync_timestamp = last_successful_sync_log.timestamp.isoformat() if last_successful_sync_log else None

            payload = {
                "sync_items": [],
                "last_sync_timestamp": last_sync_timestamp,
                "source_device_id": str(admin.server.server_id)
            }

            try:
                # Use a real HTTP client to make the external request
                response = requests.post(sync_url, json=payload, timeout=30)
                response.raise_for_status() # Raise an exception for bad status codes

                logger.info(f"Sync for admin {admin.username} to {sync_url} successful.")
                # You can process the response data here if needed
                
            except requests.exceptions.RequestException as e:
                logger.error(f"Sync failed for admin {admin.username} to {sync_url}. Error: {e}")
                # You could add logic here to trigger the fallback from parent to MCC
                # but with the current design, we've already done that with our initial if/else.

    except Exception as e:
        logger.error(f"An unexpected error occurred during periodic sync: {e}")