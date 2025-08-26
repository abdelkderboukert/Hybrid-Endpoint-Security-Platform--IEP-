# from django.conf import settings
# from rest_framework import generics, status, permissions, viewsets
# from rest_framework.permissions import IsAuthenticated
# from django.db.models import Q
# from rest_framework.response import Response
# from rest_framework.views import APIView
# from rest_framework_simplejwt.tokens import AccessToken
# from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
# from dj_rest_auth.views import LogoutView
# from django.db import transaction
# from django.utils import timezone
# from datetime import timedelta
# from .util import SystemDetector 

# from .permissions import IsLicenseActive
# from .models import Admin, User, Device, Server, LicenseKey, Policy, Threat, UserPhoto, DataIntegrityLog, SyncLog
# from .serializers import (
#     AdminRegisterSerializer, MyTokenObtainPairSerializer, AdminProfileSerializer,
#     SubAdminCreateSerializer, SubUserCreateSerializer, LicenseKeyActivateSerializer,
#     UserDetailSerializer, ServerSerializer, DeviceSerializer, SyncItemSerializer, MODEL_MAP
# )

# # Helper function for hierarchy traversal
# def get_descendant_admin_ids(root_admin):
#     descendant_ids = {root_admin.admin_id}
#     admins_to_process = [root_admin]
#     while admins_to_process:
#         current_admin = admins_to_process.pop(0)
#         children = Admin.objects.filter(parent_admin_id=current_admin)
#         for child in children:
#             descendant_ids.add(child.admin_id)
#             admins_to_process.append(child)
#     return descendant_ids

# # --- The Master Sync Endpoint ---
# class MasterSyncAPIView(APIView):
#     permission_classes = [IsAuthenticated]

#     def post(self, request, *args, **kwargs):
#         # 1. Log the request first
#         SyncLog.objects.create(admin=request.user, request_data=request.data)
        
#         # 2. Extract data from the request
#         sync_items_up = request.data.get('sync_items', [])
#         last_sync_timestamp = request.data.get('last_sync_timestamp')
#         source_device_id = request.data.get('source_device_id')
        
#         # 3. Process the Sync Up (client -> cloud)
#         processed_responses_up = self.process_sync_up(sync_items_up, request.user, source_device_id)
        
#         # 4. Process the Sync Down (cloud -> client)
#         sync_down_items = self.process_sync_down(last_sync_timestamp, request.user)
        
#         return Response({
#             "sync_up_responses": processed_responses_up,
#             "sync_down_items": sync_down_items,
#             "current_timestamp": timezone.now().isoformat(),
#             "message": "Synchronization completed successfully."
#         }, status=status.HTTP_200_OK)

#     def process_sync_up(self, sync_items, user, source_device_id):
#         processed_responses = []
#         with transaction.atomic():
#             for item in sync_items:
#                 serializer = SyncItemSerializer(data=item)
#                 if not serializer.is_valid():
#                     processed_responses.append({
#                         'temp_id': item.get('temp_id', None),
#                         'status': 'error',
#                         'errors': serializer.errors,
#                     })
#                     continue

#                 validated_data = serializer.validated_data
#                 model_name = validated_data['model_name']
#                 data = validated_data['data']
#                 action = validated_data['action']
#                 temp_id = validated_data.get('temp_id')

#                 Model = MODEL_MAP[model_name]
                
#                 try:
#                     if action == 'create':
#                         new_instance = Model.objects.create(**data)
                        
#                         new_instance.last_modified_by = user.admin_id
#                         new_instance.source_device_id = source_device_id
#                         new_instance.version = 1
#                         new_instance.save()
                        
#                         processed_responses.append({
#                             'temp_id': str(temp_id),
#                             'status': 'created',
#                             'permanent_id': str(new_instance.pk),
#                             'new_data': Model.objects.filter(pk=new_instance.pk).values().first(),
#                         })
                        
#                     elif action == 'update':
#                         instance = Model.objects.get(pk=data['id'])
                        
#                         for field, value in data.items():
#                             if field in ['id', 'last_modified', 'version']:
#                                 continue
#                             setattr(instance, field, value)
                        
#                         instance.last_modified_by = user.admin_id
#                         instance.source_device_id = source_device_id
#                         instance.version += 1
#                         instance.save()
                        
#                         processed_responses.append({
#                             'id': str(instance.pk),
#                             'status': 'updated',
#                             'new_data': Model.objects.filter(pk=instance.pk).values().first(),
#                         })
                    
#                     elif action == 'delete':
#                         instance = Model.objects.get(pk=data['id'])
#                         instance.delete()
#                         processed_responses.append({
#                             'id': str(data['id']),
#                             'status': 'deleted',
#                             'message': f"{model_name} with ID {data['id']} deleted successfully."
#                         })
                
#                 except Model.DoesNotExist:
#                     processed_responses.append({
#                         'id': data.get('id', None),
#                         'status': 'not_found',
#                         'message': f"Object {data.get('id', 'N/A')} not found in {model_name}.",
#                     })
#                 except Exception as e:
#                     processed_responses.append({
#                         'id': data.get('id', None),
#                         'status': 'error',
#                         'message': str(e),
#                     })
#         return processed_responses

#     def process_sync_down(self, last_sync_timestamp, user):
#         sync_down_list = []
        
#         if not last_sync_timestamp:
#             for Model in MODEL_MAP.values():
#                 if hasattr(Model, 'license'):
#                     queryset = Model.objects.filter(license=user.license)
#                     for instance in queryset:
#                         sync_down_list.append({
#                             'model_name': instance.__class__.__name__,
#                             'action': 'create',
#                             'data': Model.objects.filter(pk=instance.pk).values().first(),
#                         })
#             return sync_down_list
        
#         last_sync_dt = timezone.datetime.fromisoformat(last_sync_timestamp)

#         for Model in MODEL_MAP.values():
#             if not hasattr(Model, 'last_modified'):
#                 continue
                
#             queryset = Model.objects.filter(last_modified__gt=last_sync_dt)
#             if hasattr(Model, 'license'):
#                 queryset = queryset.filter(license=user.license)
            
#             for instance in queryset:
#                 item_data = {}
#                 for field in instance._meta.fields:
#                     item_data[field.name] = getattr(instance, field.name)
                
#                 sync_down_list.append({
#                     'model_name': instance.__class__.__name__,
#                     'action': 'update', 
#                     'data': item_data,
#                 })
        
#         return sync_down_list

# # Other API Views (kept for reference)
# class AdminRegisterView(generics.CreateAPIView):
#     queryset = Admin.objects.all()
#     permission_classes = [permissions.AllowAny]
#     serializer_class = AdminRegisterSerializer

# class CustomLoginView(TokenObtainPairView):
#     serializer_class = MyTokenObtainPairSerializer

# class CustomLogoutView(LogoutView):
#     def post(self, request, *args, **kwargs):
#         response = super().post(request, *args, **kwargs)
#         response.delete_cookie('access_token', path='/')
#         response.delete_cookie('refresh_token', path='/')
#         return response

# class CustomTokenRefreshView(TokenRefreshView):
#     def post(self, request, *args, **kwargs):
#         refresh_token = request.COOKIES.get('refresh_token')
#         if refresh_token:
#             request.data['refresh'] = refresh_token
#         response = super().post(request, *args, **kwargs)
#         if response.status_code == 200:
#             access_token = response.data.get('access')
#             decoded_token = AccessToken(access_token)
#             response.data['access_token_exp'] = decoded_token['exp']
#             access_token_lifetime = settings.SIMPLE_JWT['ACCESS_TOKEN_LIFETIME']
#             response.set_cookie(
#                 key='access_token', value=access_token, httponly=True, samesite='Lax', 
#                 secure=False, path='/', max_age=access_token_lifetime.total_seconds()
#             )
#         return response

# class AdminProfileView(generics.RetrieveUpdateAPIView):
#     serializer_class = AdminProfileSerializer
#     permission_classes = [IsAuthenticated]#, IsLicenseActive
#     def get_object(self):
#         return self.request.user

# class LicenseKeyActivateView(generics.GenericAPIView):
#     serializer_class = LicenseKeyActivateSerializer
#     permission_classes = [IsAuthenticated]

#     def post(self, request, *args, **kwargs):
#         admin = request.user
#         serializer = self.get_serializer(data=request.data)
#         serializer.is_valid(raise_exception=True)
#         key_from_user = serializer.validated_data['key']
        
#         if admin.layer != 0:
#             return Response({"error": "Only Layer 0 admins can activate a license key."}, status=status.HTTP_403_FORBIDDEN)
#         if admin.license is not None:
#             return Response({"error": "Your account already has an active license."}, status=status.HTTP_400_BAD_REQUEST)
        
#         try:
#             license_obj = LicenseKey.objects.get(key=key_from_user)
#         except LicenseKey.DoesNotExist:
#             return Response({"error": "Invalid license key."}, status=status.HTTP_404_NOT_FOUND)
        
#         if license_obj.is_active or license_obj.assigned_admin is not None:
#             return Response({"error": "This license key has already been used."}, status=status.HTTP_400_BAD_REQUEST)

#         license_obj.is_active = True
#         license_obj.assigned_admin = admin
#         license_obj.save()
#         admin.license = license_obj
#         admin.save()
#         return Response({"message": "License activated successfully."}, status=status.HTTP_200_OK)

# class SubAdminCreateView(generics.CreateAPIView):
#     serializer_class = SubAdminCreateSerializer
#     permission_classes = [IsAuthenticated, IsLicenseActive]

#     def perform_create(self, serializer):
#         creating_admin = self.request.user
#         serializer.save(parent_admin_id=creating_admin, license=creating_admin.license)

#     def get_serializer_context(self):
#         return {'request': self.request}

# class SubUserCreateView(generics.CreateAPIView):
#     serializer_class = SubUserCreateSerializer
#     permission_classes = [IsAuthenticated, IsLicenseActive]

#     def perform_create(self, serializer):
#         creating_admin = self.request.user
#         serializer.save(parent_admin_id=creating_admin, license=creating_admin.license)

# class AdminViewSet(viewsets.ReadOnlyModelViewSet):
#     serializer_class = AdminProfileSerializer
#     permission_classes = [IsAuthenticated,IsLicenseActive]
#     queryset = Admin.objects.all()

#     def get_queryset(self):
#         user = self.request.user
#         if not user.license:
#             return self.queryset.model.objects.none()
        
#         queryset = self.queryset.filter(license=user.license)
#         network_admin_ids = get_descendant_admin_ids(user)
#         return queryset.filter(admin_id__in=network_admin_ids, layer__gt=user.layer)

# class UserViewSet(viewsets.ReadOnlyModelViewSet):
#     serializer_class = UserDetailSerializer
#     permission_classes = [IsAuthenticated, IsLicenseActive]
#     queryset = User.objects.all()

#     def get_queryset(self):
#         user = self.request.user
#         if not user.license:
#             return self.queryset.model.objects.none()
        
#         queryset = self.queryset.filter(license=user.license)
#         network_admin_ids = get_descendant_admin_ids(user)
#         return queryset.filter(parent_admin_id__in=network_admin_ids)

# class ServerViewSet(viewsets.ModelViewSet):
#     serializer_class = ServerSerializer
#     permission_classes = [IsAuthenticated, IsLicenseActive]

#     def get_queryset(self):
#         user = self.request.user
#         if not user.license:
#             return Server.objects.none()
#         admins_in_license = Admin.objects.filter(license=user.license)
#         server_ids = admins_in_license.values_list('server_id', flat=True).distinct()
#         return Server.objects.filter(server_id__in=server_ids)

# class DeviceViewSet(viewsets.ModelViewSet):
#     serializer_class = DeviceSerializer
#     permission_classes = [IsAuthenticated, IsLicenseActive]

#     def get_queryset(self):
#         user = self.request.user
#         if not user.license:
#             return Device.objects.none()
#         admins_in_license = Admin.objects.filter(license=user.license)
#         server_ids = admins_in_license.values_list('server_id', flat=True).distinct()
#         network_servers = Server.objects.filter(server_id__in=server_ids)
#         return Device.objects.filter(server__in=network_servers)
    
# class ProtectedView(generics.GenericAPIView):
#     permission_classes = [IsAuthenticated]

#     def get(self, request):
#         return Response({"message": "You have access to this protected data!"})
    


# class ServerDetectionAPIView(APIView):
#     # This view requires a logged-in admin to perform the action.
#     permission_classes = [IsAuthenticated]

#     def post(self, request, *args, **kwargs):
#         """
#         Detects system info, then creates or updates a server record.
#         """
#         admin = request.user # The logged-in admin

#         # 1. Automatically get the server information using the SystemDetector utility
#         try:
#             detector = SystemDetector()
#             server_data = detector.get_complete_system_info()
#         except Exception as e:
#             # If detection fails, send an error response
#             return Response(
#                 {"error": f"Failed to detect system information: {str(e)}"},
#                 status=status.HTTP_500_INTERNAL_SERVER_ERROR
#             )

#         hostname = server_data.get('hostname')
#         mac_address = server_data.get('mac_address')

#         if not hostname and not mac_address:
#             return Response(
#                 {"error": "Hostname or MAC address is required for a server record."},
#                 status=status.HTTP_400_BAD_REQUEST
#             )

#         try:
#             # 2. Check the database for an existing server
#             server_instance = Server.objects.get(Q(hostname=hostname) | Q(mac_address=mac_address))

#             # Check if the logged-in admin has permission to update this server
#             if server_instance.owner_admin and server_instance.owner_admin != admin and admin.layer >= server_instance.owner_admin.layer:
#                 return Response(
#                     {"error": "You do not have permission to update this server."},
#                     status=status.HTTP_403_FORBIDDEN
#                 )

#             # 3. Update the existing server record
#             serializer = ServerSerializer(server_instance, data=server_data, partial=True)
#             if serializer.is_valid():
#                 serializer.save(
#                     last_info_update=timezone.now(),
#                     auto_detected=True
#                 )
#                 return Response({
#                     "message": "Server information updated successfully.",
#                     "server": serializer.data
#                 }, status=status.HTTP_200_OK)
#             else:
#                 return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

#         except Server.DoesNotExist:
#             # 3. If the server does not exist, create a new one
#             server_data['owner_admin'] = admin.admin_id
#             serializer = ServerSerializer(data=server_data)
#             if serializer.is_valid():
#                 serializer.save(
#                     owner_admin=admin,
#                     last_info_update=timezone.now(),
#                     auto_detected=True,
#                     server_type='Local' # Assuming this is a local detection
#                 )
#                 return Response({
#                     "message": "New server registered successfully.",
#                     "server": serializer.data
#                 }, status=status.HTTP_201_CREATED)
#             else:
#                 return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

###################################################################################

# # views.py

# from django.conf import settings
# from rest_framework import generics, status, permissions, viewsets
# from rest_framework.permissions import IsAuthenticated
# from django.db.models import Q
# from rest_framework.response import Response
# from rest_framework.views import APIView
# from rest_framework_simplejwt.tokens import AccessToken
# from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
# from dj_rest_auth.views import LogoutView
# from django.db import transaction
# from django.utils import timezone
# from datetime import timedelta
# from .util import SystemDetector

# from .permissions import IsLicenseActive
# from .models import Admin, User, Device, Server, LicenseKey, Policy, Threat, UserPhoto, DataIntegrityLog, SyncLog
# from .serializers import (
#     AdminRegisterSerializer, MyTokenObtainPairSerializer, AdminProfileSerializer,
#     SubAdminCreateSerializer, SubUserCreateSerializer, LicenseKeyActivateSerializer,
#     UserDetailSerializer, ServerSerializer, DeviceSerializer, SyncItemSerializer, MODEL_MAP
# )

# # Helper function for hierarchy traversal
# def get_descendant_admin_ids(root_admin):
#     descendant_ids = {root_admin.admin_id}
#     admins_to_process = [root_admin]
#     while admins_to_process:
#         current_admin = admins_to_process.pop(0)
#         children = Admin.objects.filter(parent_admin_id=current_admin)
#         for child in children:
#             descendant_ids.add(child.admin_id)
#             admins_to_process.append(child)
#     return descendant_ids


# # --- New Centralized Sync Logging Utility Function ---
# def create_sync_item_and_log(user, model_name, action, data, temp_id=None):
#     """
#     Creates a sync item payload and logs it for later synchronization.
#     This function is called by all views that modify local data.
#     """
#     try:
#         if temp_id and isinstance(temp_id, (int, str)):
#             temp_id = str(temp_id)

#         sync_item = {
#             "model_name": model_name,
#             "action": action,
#             "temp_id": temp_id,
#             "data": data
#         }

#         # Log the item for the MasterSyncAPIView to process later
#         SyncLog.objects.create(
#             admin=user,
#             request_data={'sync_items': [sync_item]}
#         )
#         return True, "Sync item logged successfully."
#     except KeyError:
#         return False, f"Model '{model_name}' not found."
#     except Exception as e:
#         return False, str(e)


# # --- The Master Sync Endpoint ---
# class MasterSyncAPIView(APIView):
#     """
#     The main endpoint for bidirectional synchronization.
#     It handles both receiving changes (Sync Up) and sending new data (Sync Down).
#     """
#     permission_classes = [IsAuthenticated]

#     def post(self, request, *args, **kwargs):
#         # 1. Log the request first
#         SyncLog.objects.create(admin=request.user, request_data=request.data)
        
#         # 2. Extract data from the request
#         sync_items_up = request.data.get('sync_items', [])
#         last_sync_timestamp = request.data.get('last_sync_timestamp')
#         source_device_id = request.data.get('source_device_id')
        
#         # 3. Process the Sync Up (client -> cloud)
#         processed_responses_up = self.process_sync_up(sync_items_up, request.user, source_device_id)
        
#         # 4. Process the Sync Down (cloud -> client)
#         sync_down_items = self.process_sync_down(last_sync_timestamp, request.user)
        
#         return Response({
#             "sync_up_responses": processed_responses_up,
#             "sync_down_items": sync_down_items,
#             "current_timestamp": timezone.now().isoformat(),
#             "message": "Synchronization completed successfully."
#         }, status=status.HTTP_200_OK)

#     def process_sync_up(self, sync_items, user, source_device_id):
#         processed_responses = []
#         with transaction.atomic():
#             for item in sync_items:
#                 serializer = SyncItemSerializer(data=item)
#                 if not serializer.is_valid():
#                     processed_responses.append({
#                         'temp_id': item.get('temp_id', None),
#                         'status': 'error',
#                         'errors': serializer.errors,
#                     })
#                     continue

#                 validated_data = serializer.validated_data
#                 model_name = validated_data['model_name']
#                 data = validated_data['data']
#                 action = validated_data['action']
#                 temp_id = validated_data.get('temp_id')

#                 Model = MODEL_MAP.get(model_name)
#                 if not Model:
#                     processed_responses.append({
#                         'temp_id': temp_id, 'status': 'error', 'message': f"Model '{model_name}' not found."
#                     })
#                     continue
                
#                 try:
#                     if action == 'create':
#                         # Use data directly for create
#                         new_instance = Model.objects.create(**data)
                        
#                         # Set default audit fields
#                         new_instance.last_modified_by = user.admin_id
#                         new_instance.source_device_id = source_device_id
#                         new_instance.version = 1
#                         new_instance.save()
                        
#                         processed_responses.append({
#                             'temp_id': str(temp_id),
#                             'status': 'created',
#                             'permanent_id': str(new_instance.pk),
#                             'new_data': Model.objects.filter(pk=new_instance.pk).values().first(),
#                         })
                        
#                     elif action == 'update':
#                         instance = Model.objects.get(pk=data['id'])
                        
#                         for field, value in data.items():
#                             if field in ['id', 'last_modified', 'version']:
#                                 continue
#                             setattr(instance, field, value)
                        
#                         instance.last_modified_by = user.admin_id
#                         instance.source_device_id = source_device_id
#                         instance.version += 1
#                         instance.save()
                        
#                         processed_responses.append({
#                             'id': str(instance.pk),
#                             'status': 'updated',
#                             'new_data': Model.objects.filter(pk=instance.pk).values().first(),
#                         })
                    
#                     elif action == 'delete':
#                         instance = Model.objects.get(pk=data['id'])
#                         instance.delete()
#                         processed_responses.append({
#                             'id': str(data['id']),
#                             'status': 'deleted',
#                             'message': f"{model_name} with ID {data['id']} deleted successfully."
#                         })
                
#                 except Model.DoesNotExist:
#                     processed_responses.append({
#                         'id': data.get('id', None),
#                         'status': 'not_found',
#                         'message': f"Object {data.get('id', 'N/A')} not found in {model_name}.",
#                     })
#                 except Exception as e:
#                     processed_responses.append({
#                         'id': data.get('id', None),
#                         'status': 'error',
#                         'message': str(e),
#                     })
#         return processed_responses

#     def process_sync_down(self, last_sync_timestamp, user):
#         sync_down_list = []
        
#         # Case 1: First time sync, send all data
#         if not last_sync_timestamp:
#             for Model in MODEL_MAP.values():
#                 if hasattr(Model, 'license'):
#                     queryset = Model.objects.filter(license=user.license)
#                     for instance in queryset:
#                         sync_down_list.append({
#                             'model_name': instance.__class__.__name__,
#                             'action': 'create',
#                             'data': Model.objects.filter(pk=instance.pk).values().first(),
#                         })
#             return sync_down_list
        
#         # Case 2: Delta sync, send only modified data
#         try:
#             last_sync_dt = timezone.datetime.fromisoformat(last_sync_timestamp)
#         except ValueError:
#             return [] # Invalid timestamp, return empty list

#         for Model in MODEL_MAP.values():
#             if not hasattr(Model, 'last_modified'):
#                 continue
                
#             queryset = Model.objects.filter(last_modified__gt=last_sync_dt)
#             if hasattr(Model, 'license'):
#                 queryset = queryset.filter(license=user.license)
            
#             for instance in queryset:
#                 item_data = {}
#                 for field in instance._meta.fields:
#                     item_data[field.name] = getattr(instance, field.name)
                
#                 sync_down_list.append({
#                     'model_name': instance.__class__.__name__,
#                     'action': 'update', 
#                     'data': item_data,
#                 })
        
#         return sync_down_list

# # --- Other API Views (Modified to use the new sync utility) ---

# class AdminRegisterView(generics.CreateAPIView):
#     queryset = Admin.objects.all()
#     permission_classes = [permissions.AllowAny]
#     serializer_class = AdminRegisterSerializer

# class CustomLoginView(TokenObtainPairView):
#     serializer_class = MyTokenObtainPairSerializer

# class CustomLogoutView(LogoutView):
#     def post(self, request, *args, **kwargs):
#         response = super().post(request, *args, **kwargs)
#         response.delete_cookie('access_token', path='/')
#         response.delete_cookie('refresh_token', path='/')
#         return response

# class CustomTokenRefreshView(TokenRefreshView):
#     def post(self, request, *args, **kwargs):
#         refresh_token = request.COOKIES.get('refresh_token')
#         if refresh_token:
#             request.data['refresh'] = refresh_token
#         response = super().post(request, *args, **kwargs)
#         if response.status_code == 200:
#             access_token = response.data.get('access')
#             decoded_token = AccessToken(access_token)
#             response.data['access_token_exp'] = decoded_token['exp']
#             access_token_lifetime = settings.SIMPLE_JWT['ACCESS_TOKEN_LIFETIME']
#             response.set_cookie(
#                 key='access_token', value=access_token, httponly=True, samesite='Lax', 
#                 secure=False, path='/', max_age=access_token_lifetime.total_seconds()
#             )
#         return response

# class AdminProfileView(generics.RetrieveUpdateAPIView):
#     serializer_class = AdminProfileSerializer
#     permission_classes = [IsAuthenticated]
    
#     def get_object(self):
#         return self.request.user

#     def perform_update(self, serializer):
#         with transaction.atomic():
#             instance = serializer.save()
#             create_sync_item_and_log(
#                 user=self.request.user,
#                 model_name="Admin",
#                 action="update",
#                 data=serializer.data,
#                 temp_id=instance.pk
#             )
#         return Response(serializer.data)

# class LicenseKeyActivateView(generics.GenericAPIView):
#     serializer_class = LicenseKeyActivateSerializer
#     permission_classes = [IsAuthenticated]

#     def post(self, request, *args, **kwargs):
#         admin = request.user
#         serializer = self.get_serializer(data=request.data)
#         serializer.is_valid(raise_exception=True)
#         key_from_user = serializer.validated_data['key']
        
#         if admin.layer != 0:
#             return Response({"error": "Only Layer 0 admins can activate a license key."}, status=status.HTTP_403_FORBIDDEN)
#         if admin.license is not None:
#             return Response({"error": "Your account already has an active license."}, status=status.HTTP_400_BAD_REQUEST)
        
#         try:
#             license_obj = LicenseKey.objects.get(key=key_from_user)
#         except LicenseKey.DoesNotExist:
#             return Response({"error": "Invalid license key."}, status=status.HTTP_404_NOT_FOUND)
        
#         if license_obj.is_active or license_obj.assigned_admin is not None:
#             return Response({"error": "This license key has already been used."}, status=status.HTTP_400_BAD_REQUEST)

#         with transaction.atomic():
#             license_obj.is_active = True
#             license_obj.assigned_admin = admin
#             license_obj.save()
#             admin.license = license_obj
#             admin.save()
            
#             # Log the license key creation/update for synchronization
#             create_sync_item_and_log(
#                 user=admin,
#                 model_name="LicenseKey",
#                 action="update",
#                 data=LicenseKeyActivateSerializer(license_obj).data,
#                 temp_id=license_obj.pk
#             )
#         return Response({"message": "License activated successfully."}, status=status.HTTP_200_OK)

# class SubAdminCreateView(generics.CreateAPIView):
#     serializer_class = SubAdminCreateSerializer
#     permission_classes = [IsAuthenticated, IsLicenseActive]

#     def perform_create(self, serializer):
#         with transaction.atomic():
#             creating_admin = self.request.user
#             instance = serializer.save(parent_admin_id=creating_admin, license=creating_admin.license)
            
#             create_sync_item_and_log(
#                 user=creating_admin,
#                 model_name="Admin",
#                 action="create",
#                 data=serializer.data,
#                 temp_id=instance.pk
#             )

# class SubUserCreateView(generics.CreateAPIView):
#     serializer_class = SubUserCreateSerializer
#     permission_classes = [IsAuthenticated, IsLicenseActive]

#     def perform_create(self, serializer):
#         with transaction.atomic():
#             creating_admin = self.request.user
#             instance = serializer.save(parent_admin_id=creating_admin, license=creating_admin.license)
            
#             create_sync_item_and_log(
#                 user=creating_admin,
#                 model_name="User",
#                 action="create",
#                 data=serializer.data,
#                 temp_id=instance.pk
#             )

# class AdminViewSet(viewsets.ReadOnlyModelViewSet):
#     serializer_class = AdminProfileSerializer
#     permission_classes = [IsAuthenticated,IsLicenseActive]
#     queryset = Admin.objects.all()

#     def get_queryset(self):
#         user = self.request.user
#         if not user.license:
#             return self.queryset.model.objects.none()
        
#         queryset = self.queryset.filter(license=user.license)
#         network_admin_ids = get_descendant_admin_ids(user)
#         return queryset.filter(admin_id__in=network_admin_ids, layer__gt=user.layer)

# class UserViewSet(viewsets.ModelViewSet):
#     serializer_class = UserDetailSerializer
#     permission_classes = [IsAuthenticated, IsLicenseActive]
#     queryset = User.objects.all()

#     def get_queryset(self):
#         user = self.request.user
#         if not user.license:
#             return self.queryset.model.objects.none()
        
#         queryset = self.queryset.filter(license=user.license)
#         network_admin_ids = get_descendant_admin_ids(user)
#         return queryset.filter(parent_admin_id__in=network_admin_ids)

#     def perform_update(self, serializer):
#         with transaction.atomic():
#             instance = serializer.save()
#             create_sync_item_and_log(
#                 user=self.request.user,
#                 model_name="User",
#                 action="update",
#                 data=serializer.data,
#                 temp_id=instance.pk
#             )

#     def perform_destroy(self, instance):
#         with transaction.atomic():
#             pk = instance.pk
#             create_sync_item_and_log(
#                 user=self.request.user,
#                 model_name="User",
#                 action="delete",
#                 data={'id': pk}
#             )
#             instance.delete()

# class ServerViewSet(viewsets.ModelViewSet):
#     serializer_class = ServerSerializer
#     permission_classes = [IsAuthenticated, IsLicenseActive]

#     def get_queryset(self):
#         user = self.request.user
#         if not user.license:
#             return Server.objects.none()
#         admins_in_license = Admin.objects.filter(license=user.license)
#         server_ids = admins_in_license.values_list('server_id', flat=True).distinct()
#         return Server.objects.filter(server_id__in=server_ids)

#     def perform_create(self, serializer):
#         with transaction.atomic():
#             instance = serializer.save()
#             create_sync_item_and_log(
#                 user=self.request.user,
#                 model_name="Server",
#                 action="create",
#                 data=serializer.data,
#                 temp_id=instance.pk
#             )

#     def perform_update(self, serializer):
#         with transaction.atomic():
#             instance = serializer.save()
#             create_sync_item_and_log(
#                 user=self.request.user,
#                 model_name="Server",
#                 action="update",
#                 data=serializer.data,
#                 temp_id=instance.pk
#             )

#     def perform_destroy(self, instance):
#         with transaction.atomic():
#             pk = instance.pk
#             create_sync_item_and_log(
#                 user=self.request.user,
#                 model_name="Server",
#                 action="delete",
#                 data={'id': pk}
#             )
#             instance.delete()

# class DeviceViewSet(viewsets.ModelViewSet):
#     serializer_class = DeviceSerializer
#     permission_classes = [IsAuthenticated, IsLicenseActive]

#     def get_queryset(self):
#         user = self.request.user
#         if not user.license:
#             return Device.objects.none()
#         admins_in_license = Admin.objects.filter(license=user.license)
#         server_ids = admins_in_license.values_list('server_id', flat=True).distinct()
#         network_servers = Server.objects.filter(server_id__in=server_ids)
#         return Device.objects.filter(server__in=network_servers)

#     def perform_create(self, serializer):
#         with transaction.atomic():
#             instance = serializer.save()
#             create_sync_item_and_log(
#                 user=self.request.user,
#                 model_name="Device",
#                 action="create",
#                 data=serializer.data,
#                 temp_id=instance.pk
#             )

#     def perform_update(self, serializer):
#         with transaction.atomic():
#             instance = serializer.save()
#             create_sync_item_and_log(
#                 user=self.request.user,
#                 model_name="Device",
#                 action="update",
#                 data=serializer.data,
#                 temp_id=instance.pk
#             )

#     def perform_destroy(self, instance):
#         with transaction.atomic():
#             pk = instance.pk
#             create_sync_item_and_log(
#                 user=self.request.user,
#                 model_name="Device",
#                 action="delete",
#                 data={'id': pk}
#             )
#             instance.delete()

# class ProtectedView(generics.GenericAPIView):
#     permission_classes = [IsAuthenticated]
#     def get(self, request):
#         return Response({"message": "You have access to this protected data!"})
    
# class ServerDetectionAPIView(APIView):
#     permission_classes = [IsAuthenticated]

#     def post(self, request, *args, **kwargs):
#         admin = request.user
        
#         try:
#             detector = SystemDetector()
#             server_data = detector.get_complete_system_info()
#         except Exception as e:
#             return Response(
#                 {"error": f"Failed to detect system information: {str(e)}"},
#                 status=status.HTTP_500_INTERNAL_SERVER_ERROR
#             )

#         hostname = server_data.get('hostname')
#         mac_address = server_data.get('mac_address')

#         if not hostname and not mac_address:
#             return Response(
#                 {"error": "Hostname or MAC address is required for a server record."},
#                 status=status.HTTP_400_BAD_REQUEST
#             )

#         try:
#             server_instance = Server.objects.get(Q(hostname=hostname) | Q(mac_address=mac_address))

#             if server_instance.owner_admin and server_instance.owner_admin != admin and admin.layer >= server_instance.owner_admin.layer:
#                 return Response(
#                     {"error": "You do not have permission to update this server."},
#                     status=status.HTTP_403_FORBIDDEN
#                 )

#             serializer = ServerSerializer(server_instance, data=server_data, partial=True)
#             if serializer.is_valid():
#                 with transaction.atomic():
#                     serializer.save(
#                         last_info_update=timezone.now(),
#                         auto_detected=True
#                     )
#                     create_sync_item_and_log(
#                         user=admin,
#                         model_name="Server",
#                         action="update",
#                         data=serializer.data,
#                         temp_id=serializer.instance.pk
#                     )
#                 return Response({
#                     "message": "Server information updated and logged for sync.",
#                     "server": serializer.data
#                 }, status=status.HTTP_200_OK)
#             else:
#                 return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

#         except Server.DoesNotExist:
#             server_data['owner_admin'] = admin.admin_id
#             serializer = ServerSerializer(data=server_data)
#             if serializer.is_valid():
#                 with transaction.atomic():
#                     new_server = serializer.save(
#                         owner_admin=admin,
#                         last_info_update=timezone.now(),
#                         auto_detected=True,
#                         server_type='Local'
#                     )
#                     create_sync_item_and_log(
#                         user=admin,
#                         model_name="Server",
#                         action="create",
#                         data=serializer.data,
#                         temp_id=new_server.pk
#                     )
#                 return Response({
#                     "message": "New server registered and logged for sync.",
#                     "server": serializer.data
#                 }, status=status.HTTP_201_CREATED)
#             else:
#                 return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

###########################################################################


# views.py

from django.conf import settings
from rest_framework import generics, status, permissions, viewsets
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import AccessToken
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from dj_rest_auth.views import LogoutView
from django.db import transaction
from django.utils import timezone
from datetime import timedelta
from .util import SystemDetector
import uuid
import json


from .permissions import IsLicenseActive
from .models import Admin, User, Device, Server, LicenseKey, Policy, Threat, UserPhoto, DataIntegrityLog, SyncLog, Group
from .serializers import (
    AdminRegisterSerializer, MyTokenObtainPairSerializer, AdminProfileSerializer,
    SubAdminCreateSerializer, SubUserCreateSerializer, LicenseKeyActivateSerializer,
    UserDetailSerializer, ServerSerializer, DeviceSerializer, SyncItemSerializer, MODEL_MAP, GroupSerializer
)

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


# --- New Centralized Sync Logging Utility Function ---
# def create_sync_item_and_log(user, model_name, action, data, temp_id=None):
#     """
#     Creates a sync item payload and logs it for later synchronization.
#     This function is called by all views that modify local data.
#     """
#     try:
#         if temp_id and isinstance(temp_id, (int, str)):
#             temp_id = str(temp_id)

#         sync_item = {
#             "model_name": model_name,
#             "action": action,
#             "temp_id": temp_id,
#             "data": data
#         }

#         # Log the item for the MasterSyncAPIView to process later
#         SyncLog.objects.create(
#             admin=user,
#             request_data={'sync_items': [sync_item]}
#         )
#         return True, "Sync item logged successfully."
#     except KeyError:
#         return False, f"Model '{model_name}' not found."
#     except Exception as e:
#         return False, str(e)

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

# Add a helper function to get the right serializer for a model
def get_serializer_class_for_model(Model):
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

# --- The Master Sync Endpoint ---
class MasterSyncAPIView(APIView):
    """
    The main endpoint for bidirectional synchronization.
    It handles both receiving changes (Sync Up) and sending new data (Sync Down).
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        # 1. Log the request first
        SyncLog.objects.create(admin=request.user, request_data=request.data)
        
        # 2. Extract data from the request
        sync_items_up = request.data.get('sync_items', [])
        last_sync_timestamp = request.data.get('last_sync_timestamp')
        source_device_id = request.data.get('source_device_id')
        
        # 3. Process the Sync Up (client -> cloud)
        processed_responses_up = self.process_sync_up(sync_items_up, request.user, source_device_id)
        
        # 4. Process the Sync Down (cloud -> client)
        sync_down_items = self.process_sync_down(last_sync_timestamp, request.user)
        
        return Response({
            "sync_up_responses": processed_responses_up,
            "sync_down_items": sync_down_items,
            "current_timestamp": timezone.now().isoformat(),
            "message": "Synchronization completed successfully."
        }, status=status.HTTP_200_OK)

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
                        instance = Model.objects.get(pk=data['id'])
                        
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
                    
                    elif action == 'delete':
                        instance = Model.objects.get(pk=data['id'])
                        instance.delete()
                        processed_responses.append({
                            'id': str(data['id']),
                            'status': 'deleted',
                            'message': f"{model_name} with ID {data['id']} deleted successfully."
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
                    queryset = Model.objects.filter(license=user.license)
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
        
        return sync_down_list

# --- Other API Views (Modified to use the new sync utility) ---

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
    permission_classes = [IsAuthenticated]
    
    def get_object(self):
        return self.request.user

    def perform_update(self, serializer):
        with transaction.atomic():
            instance = serializer.save()
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
            license_obj.is_active = True
            license_obj.assigned_admin = admin
            license_obj.save()
            admin.license = license_obj
            admin.save()
            
            # Log the license key creation/update for synchronization
            create_sync_item_and_log(
                user=admin,
                model_name="LicenseKey",
                action="update",
                data=LicenseKeyActivateSerializer(license_obj).data,
                temp_id=license_obj.pk
            )
        return Response({"message": "License activated successfully."}, status=status.HTTP_200_OK)

class SubAdminCreateView(generics.CreateAPIView):
    serializer_class = SubAdminCreateSerializer
    permission_classes = [IsAuthenticated, IsLicenseActive]

    def perform_create(self, serializer):
        with transaction.atomic():
            creating_admin = self.request.user
            instance = serializer.save(parent_admin_id=creating_admin, license=creating_admin.license)
            
            create_sync_item_and_log(
                user=creating_admin,
                model_name="Admin",
                action="create",
                data=serializer.data,
                temp_id=instance.pk
            )

# class SubUserCreateView(generics.CreateAPIView):
#     serializer_class = SubUserCreateSerializer
#     print(serializer_class)
#     permission_classes = [IsAuthenticated, IsLicenseActive]

#     def perform_create(self, serializer):
#         with transaction.atomic():
#             creating_admin = self.request.user
#             instance = serializer.save(parent_admin_id=creating_admin, license=creating_admin.license)
#             full_data = self.get_serializer(instance).data

#             create_sync_item_and_log(
#                 user=creating_admin,
#                 model_name="User",
#                 action="create",
#                 data=full_data,#serializer.data
#                 temp_id=instance.pk
#             )
#     print("Transaction should be committed now.") 

class SubUserCreateView(generics.CreateAPIView):
    serializer_class = SubUserCreateSerializer
    permission_classes = [IsAuthenticated, IsLicenseActive]

    def perform_create(self, serializer):
        with transaction.atomic():
            creating_admin = self.request.user
            instance = serializer.save(parent_admin_id=creating_admin, license=creating_admin.license)

            full_data = self.get_serializer(instance).data
            
            success, message = create_sync_item_and_log(
                user=creating_admin,
                model_name="User",
                action="create",
                data=full_data,
                temp_id=instance.pk
            )
            
            if not success:
                # If the sync log fails, raise an exception to trigger a rollback
                raise Exception(f"Failed to create sync log: {message}")

        print("Transaction should be committed now.")

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
            instance = serializer.save()
            create_sync_item_and_log(
                user=self.request.user,
                model_name="User",
                action="update",
                data=serializer.data,
                temp_id=instance.pk
            )

    def perform_destroy(self, instance):
        with transaction.atomic():
            pk = instance.pk
            create_sync_item_and_log(
                user=self.request.user,
                model_name="User",
                action="delete",
                data={'id': pk}
            )
            instance.delete()

class GroupViewSet(viewsets.ModelViewSet):
    serializer_class = GroupSerializer
    permission_classes = [IsAuthenticated, IsLicenseActive]
    queryset = Group.objects.all()

    def get_queryset(self):
        user = self.request.user
        if not user.license:
            return self.queryset.model.objects.none()
        return Group.objects.filter(license=user.license)

    def perform_create(self, serializer):
        with transaction.atomic():
            creating_admin = self.request.user
            instance = serializer.save(license=creating_admin.license)
            create_sync_item_and_log(
                user=creating_admin,
                model_name="Group",
                action="create",
                data=serializer.data,
                temp_id=instance.pk
            )

    def perform_update(self, serializer):
        with transaction.atomic():
            instance = serializer.save()
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Group",
                action="update",
                data=serializer.data,
                temp_id=instance.pk
            )

    def perform_destroy(self, instance):
        with transaction.atomic():
            pk = instance.pk
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Group",
                action="delete",
                data={'id': pk}
            )
            instance.delete()

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
            instance = serializer.save()
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Server",
                action="create",
                data=serializer.data,
                temp_id=instance.pk
            )

    def perform_update(self, serializer):
        with transaction.atomic():
            instance = serializer.save()
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Server",
                action="update",
                data=serializer.data,
                temp_id=instance.pk
            )

    def perform_destroy(self, instance):
        with transaction.atomic():
            pk = instance.pk
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Server",
                action="delete",
                data={'id': pk}
            )
            instance.delete()

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
            instance = serializer.save()
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Device",
                action="create",
                data=serializer.data,
                temp_id=instance.pk
            )

    def perform_update(self, serializer):
        with transaction.atomic():
            instance = serializer.save()
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Device",
                action="update",
                data=serializer.data,
                temp_id=instance.pk
            )

    def perform_destroy(self, instance):
        with transaction.atomic():
            pk = instance.pk
            create_sync_item_and_log(
                user=self.request.user,
                model_name="Device",
                action="delete",
                data={'id': pk}
            )
            instance.delete()

class ProtectedView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        return Response({"message": "You have access to this protected data!"})
    
class ServerDetectionAPIView(APIView):
    permission_classes = [IsAuthenticated]

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
                        auto_detected=True
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
                        server_type='Local'
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