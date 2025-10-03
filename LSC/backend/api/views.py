# api/views.py

from django.conf import settings
from django.db import transaction, IntegrityError
from django.db.models import Q
<<<<<<< HEAD
=======
from django.db import models
>>>>>>> develop
from django.utils import timezone
from rest_framework import generics, status, permissions, viewsets
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.tokens import AccessToken
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from dj_rest_auth.views import LogoutView
import uuid
import json
<<<<<<< HEAD
=======
import logging
>>>>>>> develop
import requests
from django.http import StreamingHttpResponse, JsonResponse
from django.views import View
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt

# Local App Imports
from .authentication import LscApiKeyAuthentication
from .models import (
    Admin, User, Device, Server, LicenseKey, Group, BootstrapToken, SyncLog
)
from .permissions import IsLicenseActive
from .serializers import (
    AdminRegisterSerializer,
    MyTokenObtainPairSerializer,
    AdminProfileSerializer,
    SubAdminCreateSerializer,
    SubUserCreateSerializer,
    LicenseKeyActivateSerializer,
    UserDetailSerializer,
    ServerSerializer,
    DeviceSerializer,
    SyncItemSerializer,
    MODEL_MAP,
<<<<<<< HEAD
    GroupSerializer,
    HierarchicalServerSerializer,
    BootstrapTokenSerializer,
)
from .util import SystemDetector


# --- NEW IMPORTS ---
from .authentication import LscApiKeyAuthentication

=======
    SERIALIZER_MAP,
    GroupSerializer,
    HierarchicalServerSerializer,
    BootstrapTokenSerializer,
    LicenseKeySerializer,
)
from .util import SystemDetector
from .authentication import LscApiKeyAuthentication

logger = logging.getLogger(__name__)

>>>>>>> develop
# Helper function for hierarchy traversal
def get_descendant_admin_ids(root_admin):
    descendant_ids = {root_admin.admin_id}
    admins_to_process = [root_admin]
    while admins_to_process:
        current_admin = admins_to_process.pop(0)
        children = Admin.objects.filter(parent_admin_id=current_admin)
        for child in children:
            descendant_ids.add(child.admin_id)
            admins_to_process.append(child)
    return descendant_ids

<<<<<<< HEAD
=======
def get_current_server():
    """
    Fetches the Server object from the database corresponding to this LSC instance.
    It identifies the server by its primary MAC address.
    """
    try:
        # Use your existing SystemDetector to get reliable network info
        detector = SystemDetector()
        UUID = detector.get_system_uuid()

        if not UUID:
            logger.error("Could not determine the UUID for this server.")
            return None
        
        # Query the Server model for a matching MAC address
        server = Server.objects.get(system_uuid=UUID)
        return server
        
    except Server.DoesNotExist:
        logger.warning(f"No server found in the database with UUID: {UUID}")
        return None
    except Server.MultipleObjectsReturned:
        logger.error(f"CRITICAL: Multiple servers found with the same UUID: {UUID}. Returning the first one.")
        return Server.objects.filter(mac_address=UUID).first()
    except Exception as e:
        logger.error(f"An unexpected error occurred while fetching the current server: {e}", exc_info=True)
        return None
>>>>>>> develop

def create_sync_item_and_log(user, model_name, action, data, temp_id=None):
    """
    Creates a sync item payload and logs it for later synchronization.
    This function is called by all views that modify local data.
    """
    try:
        # Ensure temp_id is a string, as JSONField may not handle UUIDs
        if isinstance(temp_id, uuid.UUID):
            temp_id = str(temp_id)

        # The 'data' payload might contain UUIDs, so we must serialize them
        def serialize_data(obj):
            if isinstance(obj, uuid.UUID):
                return str(obj)
            raise TypeError(f"Object of type {obj.__class__.__name__} is not JSON serializable")

        # Create a string representation of the data with UUIDs serialized
        serialized_data_str = json.dumps(data, default=serialize_data)
        serialized_data = json.loads(serialized_data_str)

        sync_item = {
            "model_name": model_name,
            "action": action,
            "temp_id": temp_id,
            "data": serialized_data
        }

        # Log the item for the MasterSyncAPIView to process later
        SyncLog.objects.create(
            admin=user,
            request_data={'sync_items': [sync_item]}
        )
        return True, "Sync item logged successfully."
    except Exception as e:
        # Re-raise the exception to force a transaction rollback.
        # This is critical for preventing a successful HTTP 201 response
        # when the database commit actually failed.
        raise e

def get_serializer_class_for_model(Model):
<<<<<<< HEAD
    if Model.__name__ == 'Admin':
        return AdminProfileSerializer
    elif Model.__name__ == 'User':
        return UserDetailSerializer
    elif Model.__name__ == 'Server':
        return ServerSerializer
    elif Model.__name__ == 'Device':
        return DeviceSerializer
    elif Model.__name__ == 'Group':
        return GroupSerializer
    return None # Or a base serializer


# class ServerRegistrationView(generics.GenericAPIView):
#     permission_classes = [permissions.AllowAny]
#     serializer_class = ServerSerializer

#     def post(self, request, *args, **kwargs):
#         token_from_client = request.data.get('bootstrap_token')
#         server_data = request.data.get('server_data')

#         if not token_from_client or not server_data:
#             return Response(
#                 {"error": "Bootstrap token and server data are required."},
#                 status=status.HTTP_400_BAD_REQUEST
#             )

#         try:
#             token = BootstrapToken.objects.select_related('created_by__license', 'created_by__server').get(token=token_from_client, is_used=False)
#         except BootstrapToken.DoesNotExist:
#             return Response({"error": "Invalid or already used bootstrap token."}, status=status.HTTP_403_FORBIDDEN)

#         with transaction.atomic():
#             token.is_used = True
#             token.save()

#             owner_username = f"lsc_admin_{server_data.get('hostname', uuid.uuid4().hex[:6])}"
            
#             try:
#                 owner_admin = Admin.objects.create_user(
#                     username=owner_username,
#                     email=f"{owner_username}@lsc.local",
#                     password=str(uuid.uuid4()),
#                     layer=token.created_by.layer + 1,
#                     parent_admin_id=token.created_by,
#                     license=token.created_by.license
#                 )
#             except IntegrityError:
#                  return Response({"error": f"An admin with username '{owner_username}' already exists. The server may already be registered."}, status=status.HTTP_409_CONFLICT)

#             server_data['owner_admin'] = owner_admin.admin_id
#             if token.created_by.server:
#                 server_data['parent_server'] = token.created_by.server.server_id

#             serializer = self.get_serializer(data=server_data)
#             serializer.is_valid(raise_exception=True)
#             new_server = serializer.save(owner_admin=owner_admin)

#             owner_admin.server = new_server
#             owner_admin.save()
        
#         return Response({
#             "message": "Server registered successfully.",
#             "api_key": str(new_server.api_key),
#             "server_id": str(new_server.server_id),
#             "admin_id": str(owner_admin.admin_id)
#         }, status=status.HTTP_201_CREATED)
=======
    return SERIALIZER_MAP.get(Model.__name__)
>>>>>>> develop

class ServerRegistrationView(generics.GenericAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = ServerSerializer

    def post(self, request, *args, **kwargs):
        token_from_client = request.data.get('bootstrap_token')
        server_data = request.data.get('server_data')
<<<<<<< HEAD
        # --- NEW: Expect the admin's UUID (ID) from the LSC's .env file ---
        owner_admin_id = request.data.get('owner_admin_id')

        print(request.data)

=======
        owner_admin_id = request.data.get('owner_admin_id')

>>>>>>> develop
        if not token_from_client or not server_data or not owner_admin_id:
            return Response(
                {"error": "Bootstrap token, server data, and owner_admin_id are required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            token = BootstrapToken.objects.select_related('created_by__license').get(token=token_from_client, is_used=False)
        except BootstrapToken.DoesNotExist:
            return Response({"error": "Invalid or already used bootstrap token."}, status=status.HTTP_403_FORBIDDEN)

<<<<<<< HEAD
        # --- MODIFIED: Find the existing admin by their primary key (UUID) ---
        try:
            owner_admin = Admin.objects.get(
                admin_id=owner_admin_id,
                license=token.created_by.license  # Security check: must be in the same license
=======
        try:
            owner_admin = Admin.objects.get(
                admin_id=owner_admin_id,
                license=token.created_by.license
>>>>>>> develop
            )
        except Admin.DoesNotExist:
            return Response({"error": f"Admin with ID '{owner_admin_id}' not found or does not belong to the correct license."}, status=status.HTTP_404_NOT_FOUND)
        
        if owner_admin.server is not None:
             return Response({"error": f"Admin '{owner_admin.username}' already owns a server."}, status=status.HTTP_409_CONFLICT)

        with transaction.atomic():
            token.is_used = True
            token.save()
            
<<<<<<< HEAD
            # This logic remains the same: ensure correct hierarchy
=======
>>>>>>> develop
            owner_admin.parent_admin_id = token.created_by
            owner_admin.layer = token.created_by.layer + 1

            server_data['owner_admin'] = owner_admin.admin_id
            if token.created_by.server:
                server_data['parent_server'] = token.created_by.server.server_id

            serializer = self.get_serializer(data=server_data)
            serializer.is_valid(raise_exception=True)
            new_server = serializer.save(owner_admin=owner_admin)

            owner_admin.server = new_server
            owner_admin.save()
        
        return Response({
            "message": "Server registered successfully.",
            "api_key": str(new_server.api_key),
            "server_id": str(new_server.server_id),
            "admin_id": str(owner_admin.admin_id)
        }, status=status.HTTP_201_CREATED)    

class MasterSyncAPIView(APIView):
<<<<<<< HEAD
    """
    The main endpoint for bidirectional synchronization.
    It handles both receiving changes (Sync Up) and sending new data (Sync Down).
    """

    def get_authenticators(self):
        """Dynamically choose authentication based on the provided token type."""
        auth_header = self.request.headers.get('Authorization', '')
        if auth_header.startswith('Bearer '):
            token = auth_header.split(' ')[1]
            # API keys are short UUIDs. JWTs are very long.
=======
    def get_authenticators(self):
        auth_header = self.request.headers.get('Authorization', '')
        if auth_header.startswith('Bearer '):
            token = auth_header.split(' ')[1]
>>>>>>> develop
            if len(token) < 100:
                return [LscApiKeyAuthentication()]
        return [JWTAuthentication()]
    
<<<<<<< HEAD

    permission_classes = [IsAuthenticated,IsLicenseActive]

    def post(self, request, *args, **kwargs):
        print(request.user)
        # 1. Log the request first
        SyncLog.objects.create(admin=request.user, request_data=request.data)
        
        # 2. Extract data from the request
=======
    permission_classes = [IsAuthenticated,IsLicenseActive]

    def post(self, request, *args, **kwargs):
        SyncLog.objects.create(admin=request.user, request_data=request.data)
        
>>>>>>> develop
        sync_items_up = request.data.get('sync_items', [])
        last_sync_timestamp = request.data.get('last_sync_timestamp')
        source_device_id = request.data.get('source_device_id')
        
<<<<<<< HEAD
        # 3. Process the Sync Up (client -> cloud)
        processed_responses_up = self.process_sync_up(sync_items_up, request.user, source_device_id)
        
        # 4. Process the Sync Down (cloud -> client)
        sync_down_items = self.process_sync_down(last_sync_timestamp, request.user)
        
=======
        processed_responses_up = self.process_sync_up(sync_items_up, request.user, source_device_id)
        if request.user.username == "local_admin_3":
            print(request.user)
            print("processed_responses_up:")
            print(processed_responses_up)
        sync_down_items = self.process_sync_down(last_sync_timestamp, request.user)
        if request.user.username == "local_admin_3":
            print("sync_down_items:")
            print(sync_down_items)

>>>>>>> develop
        return Response({
            "sync_up_responses": processed_responses_up,
            "sync_down_items": sync_down_items,
            "current_timestamp": timezone.now().isoformat(),
            "message": "Synchronization completed successfully."
        }, status=status.HTTP_200_OK)

<<<<<<< HEAD
    def process_sync_up(self, sync_items, user, source_device_id):
        processed_responses = []
        with transaction.atomic():
            for item in sync_items:
                serializer = SyncItemSerializer(data=item)
                if not serializer.is_valid():
                    processed_responses.append({
                        'temp_id': item.get('temp_id', None),
                        'status': 'error',
                        'errors': serializer.errors,
                    })
                    continue

                validated_data = serializer.validated_data
                model_name = validated_data['model_name']
                data = validated_data['data']
                action = validated_data['action']
                temp_id = validated_data.get('temp_id')

                Model = MODEL_MAP.get(model_name)
                if not Model:
                    processed_responses.append({
                        'temp_id': temp_id, 'status': 'error', 'message': f"Model '{model_name}' not found."
                    })
                    continue
                
                try:
                    record_id = data.get('id') or data.get(f'{model_name.lower()}_id')
                    
                    if action == 'create':
                        # Use serializer for create to handle nested fields like groups
                        serializer_class = get_serializer_class_for_model(Model)
                        serializer = serializer_class(data=data)
                        serializer.is_valid(raise_exception=True)
                        new_instance = serializer.save()
                        
                        # Set default audit fields
                        new_instance.last_modified_by = user.admin_id
                        new_instance.source_device_id = source_device_id
                        new_instance.version = 1
                        new_instance.save()
                        
                        processed_responses.append({
                            'temp_id': str(temp_id),
                            'status': 'created',
                            'permanent_id': str(new_instance.pk),
                            'new_data': Model.objects.filter(pk=new_instance.pk).values().first(),
                        })
                        
                    elif action == 'update':
                        instance = Model.objects.get(pk=record_id)
                        
                        # --- LAST-WRITE-WINS IMPLEMENTATION ---
                        client_last_modified = validated_data.get('client_last_modified')
                        if client_last_modified and client_last_modified > instance.last_modified:
                            # Use serializer for update to handle nested fields
                            serializer_class = get_serializer_class_for_model(Model)
                            serializer = serializer_class(instance, data=data, partial=True)
                            serializer.is_valid(raise_exception=True)
                            
                            updated_instance = serializer.save()
                            updated_instance.last_modified_by = user.admin_id
                            updated_instance.source_device_id = source_device_id
                            updated_instance.version += 1
                            updated_instance.save()
                            
                            processed_responses.append({
                                'id': str(updated_instance.pk),
                                'status': 'updated',
                                'new_data': Model.objects.filter(pk=updated_instance.pk).values().first(),
                            })
                        else:
                            # Data is older than server's, return 'stale' status so client can re-pull
                            processed_responses.append({
                                'id': str(record_id),
                                'status': 'stale',
                                'message': "Client data is older than server's. Please sync down."
                            })
                    
                    elif action == 'delete':
                        instance = Model.objects.get(pk=record_id)
                        
                        # --- SOFT DELETE IMPLEMENTATION ---
                        instance.is_deleted = True
                        instance.last_modified_by = user.admin_id
                        instance.source_device_id = source_device_id
                        instance.version += 1
                        instance.save()
                        
                        processed_responses.append({
                            'id': str(record_id),
                            'status': 'deleted',
                            'message': f"{model_name} with ID {record_id} marked as deleted successfully."
                        })
                
                except Model.DoesNotExist:
                    processed_responses.append({
                        'id': data.get('id', None),
                        'status': 'not_found',
                        'message': f"Object {data.get('id', 'N/A')} not found in {model_name}.",
                    })
                except Exception as e:
                    processed_responses.append({
                        'id': data.get('id', None),
                        'status': 'error',
                        'message': str(e),
                    })
        return processed_responses

    def process_sync_down(self, last_sync_timestamp, user):
        sync_down_list = []
        
        # Case 1: First time sync, send all data
        if not last_sync_timestamp:
            for Model in MODEL_MAP.values():
                if hasattr(Model, 'license'):
                    queryset = Model.objects.filter(license=user.license, is_deleted=False)
                    for instance in queryset:
                        sync_down_list.append({
                            'model_name': instance.__class__.__name__,
                            'action': 'create',
                            'data': Model.objects.filter(pk=instance.pk).values().first(),
                        })
            return sync_down_list
        
        # Case 2: Delta sync, send only modified data
        try:
            last_sync_dt = timezone.datetime.fromisoformat(last_sync_timestamp)
        except ValueError:
            return [] # Invalid timestamp, return empty list

        for Model in MODEL_MAP.values():
            if not hasattr(Model, 'last_modified'):
                continue
                
            queryset = Model.objects.filter(last_modified__gt=last_sync_dt)
            if hasattr(Model, 'license'):
                queryset = queryset.filter(license=user.license)
            
            for instance in queryset:
                item_data = {}
                for field in instance._meta.fields:
                    item_data[field.name] = getattr(instance, field.name)
                
                sync_down_list.append({
                    'model_name': instance.__class__.__name__,
                    'action': 'update', 
                    'data': item_data,
                })
        
=======
    # def process_sync_up(self, sync_items, user, source_device_id):
    #     processed_responses = []
    #     with transaction.atomic():
    #         for item in sync_items:
    #             serializer = SyncItemSerializer(data=item)
    #             if not serializer.is_valid():
    #                 processed_responses.append({
    #                     'temp_id': item.get('temp_id', None),
    #                     'status': 'error',
    #                     'errors': serializer.errors,
    #                 })
    #                 continue

    #             validated_data = serializer.validated_data
    #             model_name = validated_data['model_name']
    #             data = validated_data['data']
    #             action = validated_data['action']
    #             temp_id = validated_data.get('temp_id')
    #             client_last_modified = validated_data.get('client_last_modified')

    #             Model = MODEL_MAP.get(model_name)
    #             if not Model:
    #                 processed_responses.append({
    #                     'temp_id': temp_id, 'status': 'error', 'message': f"Model '{model_name}' not found."
    #                 })
    #                 continue
                
    #             try:
    #                 pk_field_name = Model._meta.pk.name
    #                 record_id = data.get(pk_field_name)
    #                 requesting_server_id = str(user.server.server_id) if user.server else None
                    
    #                 if action == 'update':
    #                     instance = Model.objects.get(pk=record_id)
                        
    #                     if str(instance.source_device_id) == requesting_server_id:
    #                         processed_responses.append({
    #                             'id': str(record_id), 'status': 'ignored_echo',
    #                             'message': 'Update ignored as it originated from this server.'
    #                         })
    #                         continue

    #                     if client_last_modified and client_last_modified > instance.last_modified:
    #                         serializer_class = get_serializer_class_for_model(Model)
    #                         serializer = serializer_class(instance, data=data, partial=True)
    #                         serializer.is_valid(raise_exception=True)
                            
    #                         updated_instance = serializer.save()
    #                         updated_instance.last_modified_by = user.admin_id
    #                         updated_instance.source_device_id = requesting_server_id
    #                         updated_instance.version += 1
    #                         updated_instance.save()
                            
    #                         processed_responses.append({'id': str(updated_instance.pk), 'status': 'updated'})
    #                     else:
    #                         processed_responses.append({'id': str(record_id), 'status': 'stale'})
                    
    #                 elif action == 'create':
    #                     serializer_class = get_serializer_class_for_model(Model)
    #                     serializer = serializer_class(data=data)
    #                     serializer.is_valid(raise_exception=True)
    #                     new_instance = serializer.save()
                        
    #                     new_instance.last_modified_by = user.admin_id
    #                     new_instance.source_device_id = requesting_server_id
    #                     new_instance.version = 1
    #                     new_instance.save()
                        
    #                     processed_responses.append({
    #                         'temp_id': str(temp_id), 'status': 'created',
    #                         'permanent_id': str(new_instance.pk),
    #                     })

    #                 elif action == 'delete':
    #                     instance = Model.objects.get(pk=record_id)
    #                     instance.is_deleted = True
    #                     instance.last_modified_by = user.admin_id
    #                     instance.source_device_id = requesting_server_id
    #                     instance.version += 1
    #                     instance.save()
                        
    #                     processed_responses.append({'id': str(record_id), 'status': 'deleted'})
                
    #             except Model.DoesNotExist:
    #                  processed_responses.append({'id': record_id, 'status': 'not_found'})
    #             except Exception as e:
    #                 processed_responses.append({'id': record_id, 'status': 'error', 'message': str(e)})
    #     return processed_responses

    # def process_sync_up(self, sync_items, user, source_device_id):
    #     processed_responses = []
    #     requesting_server_id = str(user.server.server_id) if user.server else None

    #     with transaction.atomic():
    #         for item in sync_items:
    #             # --- Step 1: Validate the incoming item structure first ---
    #             sync_item_serializer = SyncItemSerializer(data=item)
    #             if not sync_item_serializer.is_valid():
    #                 processed_responses.append({
    #                     'temp_id': item.get('temp_id', None),
    #                     'status': 'error',
    #                     'errors': sync_item_serializer.errors
    #                 })
    #                 continue

    #             validated_data = sync_item_serializer.validated_data
    #             model_name = validated_data['model_name']
    #             data = validated_data['data']
    #             action = validated_data['action']
    #             temp_id = validated_data.get('temp_id')
    #             client_last_modified = validated_data.get('client_last_modified')

    #             Model = MODEL_MAP.get(model_name)
    #             if not Model:
    #                 processed_responses.append({'temp_id': temp_id, 'status': 'error', 'message': f"Model '{model_name}' not found."})
    #                 continue
                
    #             try:
    #                 pk_field_name = Model._meta.pk.name
    #                 record_id = data.get(pk_field_name)
                    
    #                 instance = None
    #                 if record_id:
    #                     instance = Model.objects.filter(pk=record_id).first()

    #                 # --- Step 2: Handle Echo, Stale, and Update/Create logic ---
    #                 if instance and str(instance.source_device_id) == requesting_server_id:
    #                     processed_responses.append({'id': str(record_id), 'status': 'ignored_echo'})
    #                     continue

    #                 if instance and client_last_modified and client_last_modified <= instance.last_modified:
    #                     processed_responses.append({'id': str(record_id), 'status': 'stale'})
    #                     continue
                        
    #                 serializer_class = get_serializer_class_for_model(Model)
                    
    #                 # If an instance exists, it's an update.
    #                 if instance:
    #                     db_serializer = serializer_class(instance, data=data, partial=True)
    #                     action = 'update' # Force action to 'update'
    #                 # If no instance, it's a create.
    #                 else:
    #                     db_serializer = serializer_class(data=data)
    #                     action = 'create'

    #                 if db_serializer.is_valid():
    #                     # Stamp the record with the ID of the server that sent it
    #                     saved_instance = db_serializer.save(
    #                         last_modified_by=user.admin_id,
    #                         source_device_id=requesting_server_id,
    #                         last_modified=timezone.now()
    #                     )
                        
    #                     if action == 'update':
    #                         saved_instance.version += 1
    #                         saved_instance.save()
                        
    #                     response_payload = {'status': 'created' if action == 'create' else 'updated'}
    #                     if action == 'create':
    #                         response_payload['temp_id'] = temp_id
    #                         response_payload['permanent_id'] = str(saved_instance.pk)
    #                     else:
    #                         response_payload['id'] = str(saved_instance.pk)
    #                     processed_responses.append(response_payload)
                        
    #                 else:
    #                     processed_responses.append({
    #                         'id': record_id or temp_id,
    #                         'status': 'error',
    #                         'message': json.dumps(db_serializer.errors)
    #                     })

    #             except Exception as e:
    #                 logger.error(f"Error processing sync_up for {model_name}: {e}", exc_info=True)
    #                 processed_responses.append({'id': record_id or temp_id, 'status': 'error', 'message': str(e)})
                    
    #     return processed_responses
    

    # api/views.py

    def process_sync_up(self, sync_items, user, source_device_id):
        processed_responses = []
        requesting_server_id = str(user.server.server_id) if user.server else None

        with transaction.atomic():
            for item in sync_items:
                # --- Step 1: Validate the incoming item structure ---
                sync_item_serializer = SyncItemSerializer(data=item)
                if not sync_item_serializer.is_valid():
                    processed_responses.append({
                        'temp_id': item.get('temp_id', None),
                        'status': 'error', 'errors': sync_item_serializer.errors
                    })
                    continue

                validated_data = sync_item_serializer.validated_data
                model_name = validated_data['model_name']
                data = validated_data['data']
                action = validated_data['action']
                client_last_modified = validated_data.get('client_last_modified')
                
                Model = MODEL_MAP.get(model_name)
                if not Model:
                    processed_responses.append({'status': 'error', 'message': f"Model '{model_name}' not found."})
                    continue
                
                try:
                    pk_field_name = Model._meta.pk.name
                    record_id = data.get(pk_field_name)

                    if not record_id:
                        processed_responses.append({'status': 'error', 'message': f"Missing primary key for model {model_name}."})
                        continue

                    instance = Model.objects.filter(pk=record_id).first()

                    # --- Step 2: Handle Echo and Stale Data ---
                    if instance and str(instance.source_device_id) == requesting_server_id:
                        processed_responses.append({'id': str(record_id), 'status': 'ignored_echo'})
                        continue
                    if instance and client_last_modified and client_last_modified <= instance.last_modified:
                        processed_responses.append({'id': str(record_id), 'status': 'stale'})
                        continue
                        
                    # --- Step 3: Separate Data for Safe Creation/Update ---
                    fk_ids = {}
                    m2m_ids = {}
                    non_relational_data = {}

                    for key, value in data.items():
                        if key == pk_field_name: continue
                        try:
                            field = Model._meta.get_field(key)
                            if isinstance(field, (models.ForeignKey, models.OneToOneField)):
                                if value: fk_ids[f"{key}_id"] = value
                            elif isinstance(field, models.ManyToManyField):
                                if value: m2m_ids[key] = value
                            else:
                                non_relational_data[key] = value
                        except models.FieldDoesNotExist:
                            pass
                    
                    # --- Step 4: Intelligent Create/Update of the Base Object ---
                    # Use the non-relational data for the initial creation to avoid FK errors
                    obj, created = Model.objects.get_or_create(
                        pk=record_id,
                        defaults=non_relational_data
                    )

                    # --- Step 5: Apply All Other Fields and Metadata ---
                    if not created: # If it existed, update the non-relational fields
                        for key, value in non_relational_data.items():
                            setattr(obj, key, value)
                    
                    # Apply Foreign Keys
                    for key, value in fk_ids.items():
                        setattr(obj, key, value)
                    
                    # Stamp with metadata
                    obj.last_modified_by = user.admin_id
                    obj.source_device_id = requesting_server_id
                    
                    # CRITICAL FIX: Respect the client's timestamp
                    obj.last_modified = client_last_modified
                    
                    if not created:
                        obj.version += 1

                    obj.save() # Save all FKs, metadata, and non-relational updates
                    
                    # Apply M2M fields after the object is fully saved
                    if m2m_ids:
                        for field_name, value_list in m2m_ids.items():
                            manager = getattr(obj, field_name)
                            manager.set(value_list)
                    
                    if created:
                        processed_responses.append({'status': 'created', 'permanent_id': str(obj.pk)})
                    else:
                        processed_responses.append({'id': str(obj.pk), 'status': 'updated'})

                except Exception as e:
                    logger.error(f"Error processing sync_up for {model_name} with ID {record_id}: {e}", exc_info=True)
                    processed_responses.append({'id': record_id, 'status': 'error', 'message': str(e)})
                    
        return processed_responses
    def process_sync_down(self, last_sync_timestamp, user):
        sync_down_list = []
        
        queryset_filter = {}
        if last_sync_timestamp:
            try:
                last_sync_dt = timezone.datetime.fromisoformat(last_sync_timestamp)
                queryset_filter['last_modified__gt'] = last_sync_dt
            except ValueError:
                return []
            
        for model_name, Model in MODEL_MAP.items():
            if not hasattr(Model, 'last_modified'):
                continue
            
            queryset = Model.objects.filter(**queryset_filter)
            if hasattr(Model, 'license'):
                queryset = queryset.filter(license=user.license)
            
            # CRITICAL FIX: Add hierarchical filtering
            # descendant_ids = get_descendant_admin_ids(user)
            # if model_name in ['Admin', 'User', 'Group']:
            #     queryset = queryset.filter(parent_admin_id__in=descendant_ids)
            # elif model_name == 'Device':
            #     accessible_servers = Server.objects.filter(owner_admin__in=descendant_ids)
            #     queryset = queryset.filter(server__in=accessible_servers)
            # elif model_name == 'Server':
            #      queryset = queryset.filter(owner_admin__in=descendant_ids)

            serializer_class = SERIALIZER_MAP.get(model_name)
            if not serializer_class:
                continue

            for instance in queryset:
                serializer = serializer_class(instance)
                
                action = 'delete' if getattr(instance, 'is_deleted', False) else 'update'
                if not last_sync_timestamp:
                    action = 'create'

                sync_down_list.append({
                    'model_name': model_name,
                    'action': action,
                    'data': serializer.data,
                })
>>>>>>> develop
        return sync_down_list

class AdminRegisterView(generics.CreateAPIView):
    queryset = Admin.objects.all()
    permission_classes = [permissions.AllowAny]
    serializer_class = AdminRegisterSerializer

class CustomLoginView(TokenObtainPairView):
    serializer_class = MyTokenObtainPairSerializer

class CustomLogoutView(LogoutView):
    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        response.delete_cookie('access_token', path='/')
        response.delete_cookie('refresh_token', path='/')
        return response

class CustomTokenRefreshView(TokenRefreshView):
    def post(self, request, *args, **kwargs):
        refresh_token = request.COOKIES.get('refresh_token')
        if refresh_token:
            request.data['refresh'] = refresh_token
        response = super().post(request, *args, **kwargs)
        if response.status_code == 200:
            access_token = response.data.get('access')
            decoded_token = AccessToken(access_token)
            response.data['access_token_exp'] = decoded_token['exp']
            access_token_lifetime = settings.SIMPLE_JWT['ACCESS_TOKEN_LIFETIME']
            response.set_cookie(
                key='access_token', value=access_token, httponly=True, samesite='Lax', 
                secure=False, path='/', max_age=access_token_lifetime.total_seconds()
            )
        return response

class AdminProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = AdminProfileSerializer
    permission_classes = [IsAuthenticated,IsLicenseActive]
    
    def get_object(self):
        return self.request.user

    def perform_update(self, serializer):
        with transaction.atomic():
<<<<<<< HEAD
            instance = serializer.save()
=======
            # FIX: Manually set last_modified on local update
            instance = serializer.save(last_modified=timezone.now())
>>>>>>> develop
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Admin",
                action="update",
                data=serializer.data,
                temp_id=instance.pk
            )
        return Response(serializer.data)

class LicenseKeyActivateView(generics.GenericAPIView):
    serializer_class = LicenseKeyActivateSerializer
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        admin = request.user
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        key_from_user = serializer.validated_data['key']
        
        if admin.layer != 0:
            return Response({"error": "Only Layer 0 admins can activate a license key."}, status=status.HTTP_403_FORBIDDEN)
        if admin.license is not None:
            return Response({"error": "Your account already has an active license."}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            license_obj = LicenseKey.objects.get(key=key_from_user)
        except LicenseKey.DoesNotExist:
            return Response({"error": "Invalid license key."}, status=status.HTTP_404_NOT_FOUND)
        
        if license_obj.is_active or license_obj.assigned_admin is not None:
            return Response({"error": "This license key has already been used."}, status=status.HTTP_400_BAD_REQUEST)

        with transaction.atomic():
<<<<<<< HEAD
            license_obj.is_active = True
            license_obj.assigned_admin = admin
            license_obj.save()
            admin.license = license_obj
            admin.save()
            
            # Log the license key creation/update for synchronization
=======
            now = timezone.now()
            license_obj.is_active = True
            license_obj.assigned_admin = admin
            license_obj.last_modified = now  # FIX
            license_obj.save()
            
            admin.license = license_obj
            admin.last_modified = now # FIX
            admin.save()
            
>>>>>>> develop
            create_sync_item_and_log(
                user=admin,
                model_name="LicenseKey",
                action="update",
<<<<<<< HEAD
                data=LicenseKeyActivateSerializer(license_obj).data,
=======
                data=LicenseKeySerializer(license_obj).data,
>>>>>>> develop
                temp_id=license_obj.pk
            )
        return Response({"message": "License activated successfully."}, status=status.HTTP_200_OK)

class SubAdminCreateView(generics.CreateAPIView):
    serializer_class = SubAdminCreateSerializer
    permission_classes = [IsAuthenticated, IsLicenseActive]

    def perform_create(self, serializer):
        with transaction.atomic():
            creating_admin = self.request.user
<<<<<<< HEAD
            instance = serializer.save(parent_admin_id=creating_admin, license=creating_admin.license)
            
=======
            instance = serializer.save(
                parent_admin_id=creating_admin, 
                license=creating_admin.license,
                last_modified=timezone.now()  # FIX
            )
            full_data = self.get_serializer(instance).data
>>>>>>> develop
            create_sync_item_and_log(
                user=creating_admin,
                model_name="Admin",
                action="create",
<<<<<<< HEAD
                data=serializer.data,
=======
                data=full_data,
>>>>>>> develop
                temp_id=instance.pk
            )

class SubUserCreateView(generics.CreateAPIView):
    serializer_class = SubUserCreateSerializer
    permission_classes = [IsAuthenticated, IsLicenseActive]

    def perform_create(self, serializer):
        with transaction.atomic():
            creating_admin = self.request.user
<<<<<<< HEAD
            instance = serializer.save(parent_admin_id=creating_admin, license=creating_admin.license)
=======
            instance = serializer.save(
                parent_admin_id=creating_admin, 
                license=creating_admin.license,
                last_modified=timezone.now() # FIX
            )
>>>>>>> develop

            full_data = self.get_serializer(instance).data
            
            success, message = create_sync_item_and_log(
                user=creating_admin,
                model_name="User",
                action="create",
                data=full_data,
                temp_id=instance.pk
            )
            
            if not success:
<<<<<<< HEAD
                # If the sync log fails, raise an exception to trigger a rollback
                raise Exception(f"Failed to create sync log: {message}")

        print("Transaction should be committed now.")

=======
                raise Exception(f"Failed to create sync log: {message}")

>>>>>>> develop
class AdminViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = AdminProfileSerializer
    permission_classes = [IsAuthenticated,IsLicenseActive]
    queryset = Admin.objects.all()

    def get_queryset(self):
        user = self.request.user
        if not user.license:
            return self.queryset.model.objects.none()
        
        queryset = self.queryset.filter(license=user.license)
        network_admin_ids = get_descendant_admin_ids(user)
        return queryset.filter(admin_id__in=network_admin_ids, layer__gt=user.layer)

class UserViewSet(viewsets.ModelViewSet):
    serializer_class = UserDetailSerializer
    permission_classes = [IsAuthenticated, IsLicenseActive]
    queryset = User.objects.all()

    def get_queryset(self):
        user = self.request.user
        if not user.license:
            return self.queryset.model.objects.none()
        
        queryset = self.queryset.filter(license=user.license)
        network_admin_ids = get_descendant_admin_ids(user)
        return queryset.filter(parent_admin_id__in=network_admin_ids)

    def perform_update(self, serializer):
        with transaction.atomic():
<<<<<<< HEAD
            instance = serializer.save()
=======
            instance = serializer.save(last_modified=timezone.now()) # FIX
>>>>>>> develop
            create_sync_item_and_log(
                user=self.request.user,
                model_name="User",
                action="update",
                data=serializer.data,
                temp_id=instance.pk
            )

    def perform_destroy(self, instance):
        with transaction.atomic():
<<<<<<< HEAD
            # Soft delete the instance by setting is_deleted to True
            instance.is_deleted = True
=======
            instance.is_deleted = True
            instance.last_modified = timezone.now() # FIX
>>>>>>> develop
            instance.save()
            
            create_sync_item_and_log(
                user=self.request.user,
                model_name="User",
                action="delete",
                data={'id': str(instance.pk)}
            )
<<<<<<< HEAD

=======
>>>>>>> develop
class GroupViewSet(viewsets.ModelViewSet):
    serializer_class = GroupSerializer
    permission_classes = [IsAuthenticated, IsLicenseActive]
    queryset = Group.objects.all()

    def get_queryset(self):
        user = self.request.user
        if not user.license:
            return self.queryset.model.objects.none()
        queryset = self.queryset.filter(license=user.license)
        network_admin_ids = get_descendant_admin_ids(user)
        return queryset.filter(parent_admin_id__in=network_admin_ids)
<<<<<<< HEAD
        # return Group.objects.filter(license=user.license)
=======
>>>>>>> develop

    def perform_create(self, serializer):
        with transaction.atomic():
            creating_admin = self.request.user
<<<<<<< HEAD
            instance = serializer.save(parent_admin_id=creating_admin, license=creating_admin.license)
=======
            instance = serializer.save(
                parent_admin_id=creating_admin, 
                license=creating_admin.license,
                last_modified=timezone.now() # FIX
            )
            full_data = self.get_serializer(instance).data
>>>>>>> develop
            create_sync_item_and_log(
                user=creating_admin,
                model_name="Group",
                action="create",
<<<<<<< HEAD
                data=serializer.data,
=======
                data=full_data,
>>>>>>> develop
                temp_id=instance.pk
            )

    def perform_update(self, serializer):
        with transaction.atomic():
<<<<<<< HEAD
            instance = serializer.save()
=======
            instance = serializer.save(last_modified=timezone.now()) # FIX
            full_data = self.get_serializer(instance).data
>>>>>>> develop
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Group",
                action="update",
<<<<<<< HEAD
                data=serializer.data,
=======
                data=full_data,
>>>>>>> develop
                temp_id=instance.pk
            )

    def perform_destroy(self, instance):
        with transaction.atomic():
<<<<<<< HEAD
            # Soft delete the instance
            instance.is_deleted = True
=======
            instance.is_deleted = True
            instance.last_modified = timezone.now() # FIX
>>>>>>> develop
            instance.save()
            
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Group",
                action="delete",
                data={'id': str(instance.pk)}
            )

class ServerViewSet(viewsets.ModelViewSet):
    serializer_class = ServerSerializer
    permission_classes = [IsAuthenticated, IsLicenseActive]

    def get_queryset(self):
        user = self.request.user
        if not user.license:
            return Server.objects.none()
        admins_in_license = Admin.objects.filter(license=user.license)
        server_ids = admins_in_license.values_list('server_id', flat=True).distinct()
        return Server.objects.filter(server_id__in=server_ids)

    def perform_create(self, serializer):
        with transaction.atomic():
<<<<<<< HEAD
            instance = serializer.save()
=======
            instance = serializer.save(last_modified=timezone.now()) # FIX

            full_data = self.get_serializer(instance).data
>>>>>>> develop
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Server",
                action="create",
<<<<<<< HEAD
                data=serializer.data,
=======
                data=full_data,
>>>>>>> develop
                temp_id=instance.pk
            )

    def perform_update(self, serializer):
        with transaction.atomic():
<<<<<<< HEAD
            instance = serializer.save()
=======
            instance = serializer.save(last_modified=timezone.now()) # FIX
            full_data = self.get_serializer(instance).data
>>>>>>> develop
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Server",
                action="update",
<<<<<<< HEAD
                data=serializer.data,
=======
                data=full_data,
>>>>>>> develop
                temp_id=instance.pk
            )

    def perform_destroy(self, instance):
        with transaction.atomic():
            instance.is_deleted = True
<<<<<<< HEAD
=======
            instance.last_modified = timezone.now() # FIX
>>>>>>> develop
            instance.save()
            
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Server",
                action="delete",
                data={'id': str(instance.pk)}
            )

class DeviceViewSet(viewsets.ModelViewSet):
    serializer_class = DeviceSerializer
    permission_classes = [IsAuthenticated, IsLicenseActive]

    def get_queryset(self):
        user = self.request.user
        if not user.license:
            return Device.objects.none()
        admins_in_license = Admin.objects.filter(license=user.license)
        server_ids = admins_in_license.values_list('server_id', flat=True).distinct()
        network_servers = Server.objects.filter(server_id__in=server_ids)
        return Device.objects.filter(server__in=network_servers)

    def perform_create(self, serializer):
        with transaction.atomic():
<<<<<<< HEAD
            instance = serializer.save()
=======
            instance = serializer.save(last_modified=timezone.now()) # FIX
            full_data = self.get_serializer(instance).data
>>>>>>> develop
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Device",
                action="create",
<<<<<<< HEAD
                data=serializer.data,
=======
                data=full_data,
>>>>>>> develop
                temp_id=instance.pk
            )

    def perform_update(self, serializer):
        with transaction.atomic():
<<<<<<< HEAD
            instance = serializer.save()
=======
            instance = serializer.save(last_modified=timezone.now()) # FIX
            full_data = self.get_serializer(instance).data
>>>>>>> develop
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Device",
                action="update",
<<<<<<< HEAD
                data=serializer.data,
=======
                data=full_data,
>>>>>>> develop
                temp_id=instance.pk
            )

    def perform_destroy(self, instance):
        with transaction.atomic():
            instance.is_deleted = True
<<<<<<< HEAD
=======
            instance.last_modified = timezone.now() # FIX
>>>>>>> develop
            instance.save()
            
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Device",
                action="delete",
                data={'id': str(instance.pk)}
            )

class ProtectedView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        return Response({"message": "You have access to this protected data!"})
    
class ServerDetectionAPIView(APIView):
    permission_classes = [IsAuthenticated,IsLicenseActive]

    def post(self, request, *args, **kwargs):
        admin = request.user
        
        try:
            detector = SystemDetector()
            server_data = detector.get_complete_system_info()
        except Exception as e:
            return Response(
                {"error": f"Failed to detect system information: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        hostname = server_data.get('hostname')
        mac_address = server_data.get('mac_address')

        if not hostname and not mac_address:
            return Response(
                {"error": "Hostname or MAC address is required for a server record."},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            server_instance = Server.objects.get(Q(hostname=hostname) | Q(mac_address=mac_address))

            if server_instance.owner_admin and server_instance.owner_admin != admin and admin.layer >= server_instance.owner_admin.layer:
                return Response(
                    {"error": "You do not have permission to update this server."},
                    status=status.HTTP_403_FORBIDDEN
                )

            serializer = ServerSerializer(server_instance, data=server_data, partial=True)
            if serializer.is_valid():
                with transaction.atomic():
                    serializer.save(
                        last_info_update=timezone.now(),
<<<<<<< HEAD
                        auto_detected=True
=======
                        auto_detected=True,
                        last_modified=timezone.now() # FIX
>>>>>>> develop
                    )
                    create_sync_item_and_log(
                        user=admin,
                        model_name="Server",
                        action="update",
                        data=serializer.data,
                        temp_id=serializer.instance.pk
                    )
                return Response({
                    "message": "Server information updated and logged for sync.",
                    "server": serializer.data
                }, status=status.HTTP_200_OK)
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        except Server.DoesNotExist:
            server_data['owner_admin'] = admin.admin_id
            serializer = ServerSerializer(data=server_data)
            if serializer.is_valid():
                with transaction.atomic():
                    new_server = serializer.save(
                        owner_admin=admin,
                        last_info_update=timezone.now(),
                        auto_detected=True,
<<<<<<< HEAD
                        server_type='Local'
=======
                        server_type='Local',
                        last_modified=timezone.now() # FIX
>>>>>>> develop
                    )
                    create_sync_item_and_log(
                        user=admin,
                        model_name="Server",
                        action="create",
                        data=serializer.data,
                        temp_id=new_server.pk
                    )
                return Response({
                    "message": "New server registered and logged for sync.",
                    "server": serializer.data
                }, status=status.HTTP_201_CREATED)
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            
class ServerHierarchyView(generics.ListAPIView):
<<<<<<< HEAD
    """
    An endpoint to return a hierarchical view of top-level servers 
    and their associated devices (clients).
    """
=======
>>>>>>> develop
    serializer_class = HierarchicalServerSerializer
    permission_classes = [IsAuthenticated, IsLicenseActive]

    def get_queryset(self):
        user = self.request.user
        if not user.license:
            return Server.objects.none()
        
<<<<<<< HEAD
        # Get all server IDs associated with the current user's license
=======
>>>>>>> develop
        admins_in_license = Admin.objects.filter(license=user.license)
        server_ids_list = list(
            admins_in_license.filter(server__isnull=False)
                           .values_list('server_id', flat=True)
                           .distinct()
        )
        
<<<<<<< HEAD
        # Filter for servers that are part of the license AND are top-level (have no parent_server).
        # The serializer will handle fetching the 'children' (devices) automatically.
=======
>>>>>>> develop
        return Server.objects.filter(
            server_id__in=server_ids_list,
            parent_server__isnull=True
        ).prefetch_related('device_set')  

class BootstrapTokenCreateView(generics.CreateAPIView):
<<<<<<< HEAD
    """
    An endpoint for authenticated admins to generate new Bootstrap Tokens.
    """
=======
>>>>>>> develop
    serializer_class = BootstrapTokenSerializer
    permission_classes = [IsAuthenticated, IsLicenseActive]

    def perform_create(self, serializer):
<<<<<<< HEAD
        """
        Automatically sets the 'created_by' field to the current logged-in admin.
        """
=======
>>>>>>> develop
        serializer.save(created_by=self.request.user)

@method_decorator(csrf_exempt, name='dispatch')
class GenerateInstallerView(APIView):
<<<<<<< HEAD
    """
    Handles installer generation by first creating a new bootstrap token,
    then proxying the request to an external service.
    """
    permission_classes = [IsAuthenticated, IsLicenseActive] # <-- Add permissions

    def post(self, request, *args, **kwargs):
        # 1. Get data from the frontend request
        try:
            data = json.loads(request.body)
            print(data)
            api_key = data.get('api_key').strip("'")
            print(data.get('api_key'))
=======
    permission_classes = [IsAuthenticated, IsLicenseActive]

    def post(self, request, *args, **kwargs):
        try:
            data = json.loads(request.body)
            api_key = data.get('api_key').strip("'")
>>>>>>> develop
            owner_admin_id = data.get('owner_admin_id')
            if not api_key or not owner_admin_id:
                return JsonResponse({'error': 'API key and owner_admin_id are required.'}, status=400)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON in request body.'}, status=400)

<<<<<<< HEAD
        # 2. Fetch the server data
        try:
            server = Server.objects.get(api_key=api_key.strip("'"))
=======
        try:
            server = Server.objects.get(api_key=api_key.strip('""'))
>>>>>>> develop
        except Server.DoesNotExist:
            return JsonResponse({'error': 'Unauthorized: Invalid API key.'}, status=401)
        except Exception as e:
            return JsonResponse({'error': f'Invalid API key format: {e}'}, status=400)

<<<<<<< HEAD
        # --- NEW LOGIC: CREATE BOOTSTRAP TOKEN ---
        # 3. Create a new Bootstrap Token using the serializer
        # This replicates the logic of your BootstrapTokenCreateView
        token_serializer = BootstrapTokenSerializer(data={}) # Data is empty since it's auto-generated
        token_serializer.is_valid(raise_exception=True)
        # Save the token, associating it with the currently logged-in user
        token_instance = token_serializer.save(created_by=request.user)
        new_bootstrap_token = token_instance.token
        print("token creates seccefuly")
        # --- END OF NEW LOGIC ---

        # 4. Build the payload for the external service
=======
        token_serializer = BootstrapTokenSerializer(data={})
        token_serializer.is_valid(raise_exception=True)
        token_instance = token_serializer.save(created_by=request.user)
        new_bootstrap_token = token_instance.token
        
>>>>>>> develop
        payload = {
            'LSC_MAC_ADDRESS': server.mac_address,
            'PARENT_SERVER_ID': str(server.server_id),
            'INITIAL_PARENT_IP': server.ip_address,
            'BOOTSTRAP_TOKEN': str(new_bootstrap_token),
            'OWNER_ADMIN_ID': owner_admin_id,
        }
<<<<<<< HEAD

        print(owner_admin_id)
=======
>>>>>>> develop
        
        external_url = 'http://127.0.0.1:8001/generate-installer'

        try:
<<<<<<< HEAD
            # 5. Make the streaming request to the external service
            response = requests.post(external_url, json=payload, stream=True)
            response.raise_for_status()

            # 6. Stream the response back to the client
=======
            response = requests.post(external_url, json=payload, stream=True)
            response.raise_for_status()

>>>>>>> develop
            streaming_response = StreamingHttpResponse(
                response.iter_content(chunk_size=8192),
                content_type=response.headers.get('Content-Type'),
                status=response.status_code
            )
            content_disposition = response.headers.get('Content-Disposition')
            if content_disposition:
                streaming_response['Content-Disposition'] = content_disposition
            
            return streaming_response

        except requests.exceptions.HTTPError as e:
            return JsonResponse({'error': f'Installer generation failed: {e.response.text}'}, status=e.response.status_code)
        except requests.exceptions.RequestException as e:
            return JsonResponse({'error': f'Proxy request failed: {e}'}, status=502)