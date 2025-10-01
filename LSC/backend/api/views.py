# api/views.py

from django.conf import settings
from django.db import transaction, IntegrityError
from django.db.models import Q
from django.db import models
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
import logging
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
    SERIALIZER_MAP,
    GroupSerializer,
    HierarchicalServerSerializer,
    BootstrapTokenSerializer,
    LicenseKeySerializer,
)
from .util import SystemDetector
from .authentication import LscApiKeyAuthentication

logger = logging.getLogger(__name__)

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
    return SERIALIZER_MAP.get(Model.__name__)

class ServerRegistrationView(generics.GenericAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = ServerSerializer

    def post(self, request, *args, **kwargs):
        token_from_client = request.data.get('bootstrap_token')
        server_data = request.data.get('server_data')
        owner_admin_id = request.data.get('owner_admin_id')

        if not token_from_client or not server_data or not owner_admin_id:
            return Response(
                {"error": "Bootstrap token, server data, and owner_admin_id are required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            token = BootstrapToken.objects.select_related('created_by__license').get(token=token_from_client, is_used=False)
        except BootstrapToken.DoesNotExist:
            return Response({"error": "Invalid or already used bootstrap token."}, status=status.HTTP_403_FORBIDDEN)

        try:
            owner_admin = Admin.objects.get(
                admin_id=owner_admin_id,
                license=token.created_by.license
            )
        except Admin.DoesNotExist:
            return Response({"error": f"Admin with ID '{owner_admin_id}' not found or does not belong to the correct license."}, status=status.HTTP_404_NOT_FOUND)
        
        if owner_admin.server is not None:
             return Response({"error": f"Admin '{owner_admin.username}' already owns a server."}, status=status.HTTP_409_CONFLICT)

        with transaction.atomic():
            token.is_used = True
            token.save()
            
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
    def get_authenticators(self):
        auth_header = self.request.headers.get('Authorization', '')
        if auth_header.startswith('Bearer '):
            token = auth_header.split(' ')[1]
            if len(token) < 100:
                return [LscApiKeyAuthentication()]
        return [JWTAuthentication()]
    
    permission_classes = [IsAuthenticated,IsLicenseActive]

    def post(self, request, *args, **kwargs):
        SyncLog.objects.create(admin=request.user, request_data=request.data)
        
        sync_items_up = request.data.get('sync_items', [])
        last_sync_timestamp = request.data.get('last_sync_timestamp')
        source_device_id = request.data.get('source_device_id')
        
        processed_responses_up = self.process_sync_up(sync_items_up, request.user, source_device_id)
        if request.user.username == "local_admin_3":
            print(request.user)
            print("processed_responses_up:")
            print(processed_responses_up)
        sync_down_items = self.process_sync_down(last_sync_timestamp, request.user)
        if request.user.username == "local_admin_3":
            print("sync_down_items:")
            print(sync_down_items)

        return Response({
            "sync_up_responses": processed_responses_up,
            "sync_down_items": sync_down_items,
            "current_timestamp": timezone.now().isoformat(),
            "message": "Synchronization completed successfully."
        }, status=status.HTTP_200_OK)

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
                        'status': 'error',
                        'errors': sync_item_serializer.errors
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

                    # --- Step 2: Separate Relational and Non-Relational Data ---
                    non_relational_data = {}
                    fk_ids = {}
                    m2m_ids = {}
                    
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
                            pass # Ignore fields not in the model (like 'password2')
                    
                    # --- Step 3: Intelligent Create/Update of the Base Object ---
                    instance, created = Model.objects.get_or_create(
                        pk=record_id,
                        defaults=non_relational_data
                    )

                    # --- Step 4: Apply Relationships and Finalize ---
                    # Combine all updates into one dictionary
                    all_updates = {**fk_ids}
                    
                    # Stamp the record with metadata
                    all_updates['last_modified_by'] = user.admin_id
                    all_updates['source_device_id'] = requesting_server_id
                    all_updates['last_modified'] = timezone.now()
                    
                    if not created: # If the object already existed
                        # Update all non-relational fields
                        for key, value in non_relational_data.items():
                            setattr(instance, key, value)
                        all_updates['version'] = instance.version + 1
                    
                    # Apply all FK updates in a single efficient query
                    Model.objects.filter(pk=record_id).update(**all_updates)

                    # Handle M2M relationships separately after the instance is saved
                    if m2m_ids:
                        instance.refresh_from_db() # Ensure we have the latest version
                        for field_name, value_list in m2m_ids.items():
                            manager = getattr(instance, field_name)
                            manager.set(value_list)
                    
                    if created:
                        processed_responses.append({'status': 'created', 'permanent_id': str(instance.pk)})
                    else:
                        processed_responses.append({'id': str(instance.pk), 'status': 'updated'})

                except IntegrityError as e:
                    logger.error(f"Integrity error on sync_up for {model_name} with ID {record_id}: {e}", exc_info=True)
                    processed_responses.append({'id': record_id, 'status': 'error', 'message': f'IntegrityError: {e}'})
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
            # FIX: Manually set last_modified on local update
            instance = serializer.save(last_modified=timezone.now())
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
            now = timezone.now()
            license_obj.is_active = True
            license_obj.assigned_admin = admin
            license_obj.last_modified = now  # FIX
            license_obj.save()
            
            admin.license = license_obj
            admin.last_modified = now # FIX
            admin.save()
            
            create_sync_item_and_log(
                user=admin,
                model_name="LicenseKey",
                action="update",
                data=LicenseKeySerializer(license_obj).data,
                temp_id=license_obj.pk
            )
        return Response({"message": "License activated successfully."}, status=status.HTTP_200_OK)

class SubAdminCreateView(generics.CreateAPIView):
    serializer_class = SubAdminCreateSerializer
    permission_classes = [IsAuthenticated, IsLicenseActive]

    def perform_create(self, serializer):
        with transaction.atomic():
            creating_admin = self.request.user
            instance = serializer.save(
                parent_admin_id=creating_admin, 
                license=creating_admin.license,
                last_modified=timezone.now()  # FIX
            )
            full_data = self.get_serializer(instance).data
            create_sync_item_and_log(
                user=creating_admin,
                model_name="Admin",
                action="create",
                data=full_data,
                temp_id=instance.pk
            )

class SubUserCreateView(generics.CreateAPIView):
    serializer_class = SubUserCreateSerializer
    permission_classes = [IsAuthenticated, IsLicenseActive]

    def perform_create(self, serializer):
        with transaction.atomic():
            creating_admin = self.request.user
            instance = serializer.save(
                parent_admin_id=creating_admin, 
                license=creating_admin.license,
                last_modified=timezone.now() # FIX
            )

            full_data = self.get_serializer(instance).data
            
            success, message = create_sync_item_and_log(
                user=creating_admin,
                model_name="User",
                action="create",
                data=full_data,
                temp_id=instance.pk
            )
            
            if not success:
                raise Exception(f"Failed to create sync log: {message}")

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
            instance = serializer.save(last_modified=timezone.now()) # FIX
            create_sync_item_and_log(
                user=self.request.user,
                model_name="User",
                action="update",
                data=serializer.data,
                temp_id=instance.pk
            )

    def perform_destroy(self, instance):
        with transaction.atomic():
            instance.is_deleted = True
            instance.last_modified = timezone.now() # FIX
            instance.save()
            
            create_sync_item_and_log(
                user=self.request.user,
                model_name="User",
                action="delete",
                data={'id': str(instance.pk)}
            )
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

    def perform_create(self, serializer):
        with transaction.atomic():
            creating_admin = self.request.user
            instance = serializer.save(
                parent_admin_id=creating_admin, 
                license=creating_admin.license,
                last_modified=timezone.now() # FIX
            )
            full_data = self.get_serializer(instance).data
            create_sync_item_and_log(
                user=creating_admin,
                model_name="Group",
                action="create",
                data=full_data,
                temp_id=instance.pk
            )

    def perform_update(self, serializer):
        with transaction.atomic():
            instance = serializer.save(last_modified=timezone.now()) # FIX
            full_data = self.get_serializer(instance).data
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Group",
                action="update",
                data=full_data,
                temp_id=instance.pk
            )

    def perform_destroy(self, instance):
        with transaction.atomic():
            instance.is_deleted = True
            instance.last_modified = timezone.now() # FIX
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
            instance = serializer.save(last_modified=timezone.now()) # FIX

            full_data = self.get_serializer(instance).data
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Server",
                action="create",
                data=full_data,
                temp_id=instance.pk
            )

    def perform_update(self, serializer):
        with transaction.atomic():
            instance = serializer.save(last_modified=timezone.now()) # FIX
            full_data = self.get_serializer(instance).data
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Server",
                action="update",
                data=full_data,
                temp_id=instance.pk
            )

    def perform_destroy(self, instance):
        with transaction.atomic():
            instance.is_deleted = True
            instance.last_modified = timezone.now() # FIX
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
            instance = serializer.save(last_modified=timezone.now()) # FIX
            full_data = self.get_serializer(instance).data
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Device",
                action="create",
                data=full_data,
                temp_id=instance.pk
            )

    def perform_update(self, serializer):
        with transaction.atomic():
            instance = serializer.save(last_modified=timezone.now()) # FIX
            full_data = self.get_serializer(instance).data
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Device",
                action="update",
                data=full_data,
                temp_id=instance.pk
            )

    def perform_destroy(self, instance):
        with transaction.atomic():
            instance.is_deleted = True
            instance.last_modified = timezone.now() # FIX
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
                        auto_detected=True,
                        last_modified=timezone.now() # FIX
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
                        server_type='Local',
                        last_modified=timezone.now() # FIX
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
    serializer_class = HierarchicalServerSerializer
    permission_classes = [IsAuthenticated, IsLicenseActive]

    def get_queryset(self):
        user = self.request.user
        if not user.license:
            return Server.objects.none()
        
        admins_in_license = Admin.objects.filter(license=user.license)
        server_ids_list = list(
            admins_in_license.filter(server__isnull=False)
                           .values_list('server_id', flat=True)
                           .distinct()
        )
        
        return Server.objects.filter(
            server_id__in=server_ids_list,
            parent_server__isnull=True
        ).prefetch_related('device_set')  

class BootstrapTokenCreateView(generics.CreateAPIView):
    serializer_class = BootstrapTokenSerializer
    permission_classes = [IsAuthenticated, IsLicenseActive]

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)

@method_decorator(csrf_exempt, name='dispatch')
class GenerateInstallerView(APIView):
    permission_classes = [IsAuthenticated, IsLicenseActive]

    def post(self, request, *args, **kwargs):
        try:
            data = json.loads(request.body)
            api_key = data.get('api_key').strip("'")
            owner_admin_id = data.get('owner_admin_id')
            if not api_key or not owner_admin_id:
                return JsonResponse({'error': 'API key and owner_admin_id are required.'}, status=400)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON in request body.'}, status=400)

        try:
            server = Server.objects.get(api_key=api_key.strip('""'))
        except Server.DoesNotExist:
            return JsonResponse({'error': 'Unauthorized: Invalid API key.'}, status=401)
        except Exception as e:
            return JsonResponse({'error': f'Invalid API key format: {e}'}, status=400)

        token_serializer = BootstrapTokenSerializer(data={})
        token_serializer.is_valid(raise_exception=True)
        token_instance = token_serializer.save(created_by=request.user)
        new_bootstrap_token = token_instance.token
        
        payload = {
            'LSC_MAC_ADDRESS': server.mac_address,
            'PARENT_SERVER_ID': str(server.server_id),
            'INITIAL_PARENT_IP': server.ip_address,
            'BOOTSTRAP_TOKEN': str(new_bootstrap_token),
            'OWNER_ADMIN_ID': owner_admin_id,
        }
        
        external_url = 'http://127.0.0.1:8001/generate-installer'

        try:
            response = requests.post(external_url, json=payload, stream=True)
            response.raise_for_status()

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