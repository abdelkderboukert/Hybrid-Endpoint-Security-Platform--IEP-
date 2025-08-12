# # api/views.py

# from rest_framework import generics, status, permissions, viewsets
# from rest_framework.response import Response
# from rest_framework.permissions import AllowAny, IsAuthenticated
# from .serializers import AdminRegisterSerializer, AdminDetailSerializer,SubAdminCreateSerializer, SubUserCreateSerializer,ServerSerializer, DeviceSerializer,UserDetailSerializer,AdminProfileSerializer,LicenseKeyActivateSerializer
# from dj_rest_auth.views import LoginView, LogoutView
# from .serializers import MyTokenObtainPairSerializer
# from rest_framework_simplejwt.views import TokenObtainPairView
# from rest_framework_simplejwt.views import TokenRefreshView
# from .models import Admin,Server, Device,User
# from rest_framework_simplejwt.tokens import AccessToken

# from django.conf import settings


# class LicenseKeyActivateView(generics.GenericAPIView):
#     serializer_class = LicenseKeyActivateSerializer
#     permission_classes = [permissions.IsAuthenticated]

#     def post(self, request, *args, **kwargs):
#         admin = request.user
#         serializer = self.get_serializer(data=request.data)
#         serializer.is_valid(raise_exception=True)
#         key_from_user = serializer.validated_data['key']

#         # --- Validation Logic ---
#         # 1. Only Layer 0 admins can activate keys.
#         if admin.layer != 0:
#             return Response({"error": "Only Layer 0 admins can activate a license key."}, status=status.HTTP_403_FORBIDDEN)
        
#         # 2. An admin can only activate one key.
#         if admin.license is not None:
#             return Response({"error": "Your account already has an active license."}, status=status.HTTP_400_BAD_REQUEST)
        
#         # 3. Find the key in the database.
#         try:
#             license_obj = LicenseKey.objects.get(key=key_from_user)
#         except LicenseKey.DoesNotExist:
#             return Response({"error": "Invalid license key."}, status=status.HTTP_404_NOT_FOUND)
        
#         # 4. Check if the key is already taken by another admin.
#         if license_obj.is_active or license_obj.assigned_admin is not None:
#             return Response({"error": "This license key has already been used."}, status=status.HTTP_400_BAD_REQUEST)

#         # --- Activation ---
#         license_obj.is_active = True
#         license_obj.assigned_admin = admin
#         license_obj.save()

#         admin.license = license_obj
#         admin.save()
        
#         return Response({"message": "License activated successfully."}, status=status.HTTP_200_OK)

# class CustomLoginView(TokenObtainPairView):
#     serializer_class = MyTokenObtainPairSerializer

#     def post(self, request, *args, **kwargs):
#         response = super().post(request, *args, **kwargs)
#         if response.status_code == 200:
#             access_token = response.data.get('access')
#             refresh_token = response.data.get('refresh')
            
#             res = Response(response.data, status=status.HTTP_200_OK)
            
#             # Get token lifetimes from settings
#             access_token_lifetime = settings.SIMPLE_JWT['ACCESS_TOKEN_LIFETIME']
#             refresh_token_lifetime = settings.SIMPLE_JWT['REFRESH_TOKEN_LIFETIME']
            
#             res.set_cookie(
#                 key='access_token',
#                 value=access_token,
#                 httponly=True,
#                 samesite='Lax',
#                 secure=False,
#                 path='/',
#                 max_age=access_token_lifetime.total_seconds() # THE FIX
#             )
#             res.set_cookie(
#                 key='refresh_token',
#                 value=refresh_token,
#                 httponly=True,
#                 samesite='Lax',
#                 secure=False,
#                 path='/',
#                 max_age=refresh_token_lifetime.total_seconds() # THE FIX
#             )
#             return res
#         return response
    
# class AdminRegisterView(generics.CreateAPIView):
#     queryset = Admin.objects.all()
#     permission_classes = (AllowAny,)
#     serializer_class = AdminRegisterSerializer


# class CustomLogoutView(LogoutView):
#     def post(self, request, *args, **kwargs):
#         response = super().post(request, *args, **kwargs)
#         # Clear the HttpOnly cookies on logout
#         response.delete_cookie('access_token')
#         response.delete_cookie('refresh_token')
#         return response

# # Example protected view
# class ProtectedView(generics.GenericAPIView):
#     permission_classes = [IsAuthenticated]

#     def get(self, request):
#         return Response({"message": "You have access to this protected data!"})
    

# class AdminDetailView(generics.RetrieveAPIView):
#     """
#     Returns the details of the currently authenticated admin.
#     """
#     serializer_class = AdminDetailSerializer
#     permission_classes = [IsAuthenticated] # Ensures only logged-in users can access it

#     def get_object(self):
#         # request.user is automatically populated by Django/DRF
#         # after authenticating the request via the access_token cookie.
#         return self.request.user
    

# class CustomTokenRefreshView(TokenRefreshView):
#     """
#     This is the CORRECT version. It reads the refresh_token from a cookie
#     and sets the new access_token in a cookie.
#     """
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
#                 key='access_token',
#                 value=access_token,
#                 httponly=True, samesite='Lax', secure=False, path='/',
#                 max_age=access_token_lifetime.total_seconds()
#             )
        
#         return response


# class SubAdminCreateView(generics.CreateAPIView):
#     """
#     Endpoint for a logged-in admin to create a new sub-admin in their network.
#     """
#     serializer_class = SubAdminCreateSerializer
#     permission_classes = [permissions.IsAuthenticated]

#     def perform_create(self, serializer):
#         """
#         This method is called before saving the new object.
#         We use it to set the parent_admin_id to the currently logged-in admin.
#         """
#         creating_admin = self.request.user
#         serializer.save(parent_admin_id=creating_admin)

#     def get_serializer_context(self):
#         """
#         This passes the request object to the serializer, so it can access
#         the user who is making the request for validation.
#         """
#         return {'request': self.request}


# class SubUserCreateView(generics.CreateAPIView):
#     """
#     Endpoint for a logged-in admin to create a new user in their network.
#     """
#     serializer_class = SubUserCreateSerializer
#     permission_classes = [permissions.IsAuthenticated]

#     def perform_create(self, serializer):
#         """
#         Set the parent_admin_id to the currently logged-in admin.
#         """
#         creating_admin = self.request.user
#         serializer.save(parent_admin_id=creating_admin)


# class AdminViewSet(viewsets.ReadOnlyModelViewSet):
#     serializer_class = AdminProfileSerializer
#     permission_classes = [permissions.IsAuthenticated]

#     def get_queryset(self):
#         user = self.request.user
#         # Get all admin IDs in the current user's network
#         network_admin_ids = get_descendant_admin_ids(user)
#         # Return only admins in the network with a layer greater than the current user's
#         return Admin.objects.filter(admin_id__in=network_admin_ids, layer__gt=user.layer)


# # --- NEW: ViewSet for listing Users in the network ---
# class UserViewSet(viewsets.ReadOnlyModelViewSet):
#     serializer_class = UserDetailSerializer
#     permission_classes = [permissions.IsAuthenticated]

#     def get_queryset(self):
#         user = self.request.user
#         network_admin_ids = get_descendant_admin_ids(user)
#         # Return users whose parent admin is in the network
#         return User.objects.filter(parent_admin_id__in=network_admin_ids)


# # --- UPDATED: ServerViewSet ---
# class ServerViewSet(viewsets.ModelViewSet):
#     serializer_class = ServerSerializer
#     permission_classes = [permissions.IsAuthenticated]

#     def get_queryset(self):
#         user = self.request.user
#         network_admin_ids = get_descendant_admin_ids(user)
#         # Get the unique server IDs linked to any admin in the network
#         server_ids = Admin.objects.filter(admin_id__in=network_admin_ids).values_list('server_id', flat=True).distinct()
#         # Return only the servers that are part of the network
#         return Server.objects.filter(server_id__in=server_ids)


# # --- UPDATED: DeviceViewSet ---
# class DeviceViewSet(viewsets.ModelViewSet):
#     serializer_class = DeviceSerializer
#     permission_classes = [permissions.IsAuthenticated]

#     def get_queryset(self):
#         user = self.request.user
#         # First, find all servers in the user's network
#         network_admin_ids = get_descendant_admin_ids(user)
#         server_ids = Admin.objects.filter(admin_id__in=network_admin_ids).values_list('server_id', flat=True).distinct()
#         network_servers = Server.objects.filter(server_id__in=server_ids)
#         # Then, return only devices connected to those servers
#         return Device.objects.filter(server_id__in=network_servers)


# def get_descendant_admin_ids(root_admin):
#     """
#     Takes a root admin and returns a set containing the IDs of that admin
#     and all of their descendants in the hierarchy.
#     """
#     descendant_ids = {root_admin.admin_id}
#     # A queue to hold admins whose children we need to find
#     admins_to_process = [root_admin]

#     while admins_to_process:
#         current_admin = admins_to_process.pop(0)
#         # Find direct children of the current admin
#         children = Admin.objects.filter(parent_admin_id=current_admin)
#         for child in children:
#             descendant_ids.add(child.admin_id)
#             admins_to_process.append(child)
            
#     return descendant_ids


from django.conf import settings
from rest_framework import generics, status, permissions, viewsets
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import AccessToken
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from dj_rest_auth.views import LogoutView

from .permissions import IsLicenseActive
from .models import Admin, User, Server, Device, LicenseKey 
from .serializers import (
    AdminRegisterSerializer, MyTokenObtainPairSerializer, AdminProfileSerializer,
    SubAdminCreateSerializer, SubUserCreateSerializer, LicenseKeyActivateSerializer,
    UserDetailSerializer, ServerSerializer, DeviceSerializer
)

# --- GLOBAL FILTER MIXIN ---
class LicenseScopeMixin:
    """
    A mixin that filters querysets to only include objects
    associated with the request user's license.
    """
    def get_queryset(self):
        user = self.request.user
        
        # If the user has no license, they can't see anything.
        if not user.license:
            return self.queryset.model.objects.none()
            
        # Start by filtering for the user's license.
        # This is the base queryset that other methods will build upon.
        return self.queryset.filter(license=user.license)

# --- HELPER FUNCTION ---
def get_descendant_admin_ids(root_admin):
    """
    Takes a root admin and returns a set containing the IDs of that admin
    and all of their descendants in the hierarchy.
    """
    descendant_ids = {root_admin.admin_id}
    admins_to_process = [root_admin]

    while admins_to_process:
        current_admin = admins_to_process.pop(0)
        children = Admin.objects.filter(parent_admin_id=current_admin)
        for child in children:
            descendant_ids.add(child.admin_id)
            admins_to_process.append(child)
            
    return descendant_ids

# --- AUTHENTICATION & LICENSE VIEWS ---

class AdminRegisterView(generics.CreateAPIView):
    queryset = Admin.objects.all()
    permission_classes = [permissions.AllowAny]
    serializer_class = AdminRegisterSerializer

class CustomLoginView(TokenObtainPairView):
    serializer_class = MyTokenObtainPairSerializer

    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        if response.status_code == 200:
            access_token = response.data.get('access')
            refresh_token = response.data.get('refresh')
            res = Response(response.data, status=status.HTTP_200_OK)
            decoded_token = AccessToken(access_token)
            res.data['access_token_exp'] = decoded_token['exp']
            access_token_lifetime = settings.SIMPLE_JWT['ACCESS_TOKEN_LIFETIME']
            refresh_token_lifetime = settings.SIMPLE_JWT['REFRESH_TOKEN_LIFETIME']
            res.set_cookie(
                key='access_token', value=access_token, httponly=True, samesite='Lax', 
                secure=False, path='/', max_age=access_token_lifetime.total_seconds()
            )
            res.set_cookie(
                key='refresh_token', value=refresh_token, httponly=True, samesite='Lax', 
                secure=False, path='/', max_age=refresh_token_lifetime.total_seconds()
            )
            return res
        return response

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
    permission_classes = [permissions.IsAuthenticated, IsLicenseActive]
    def get_object(self):
        return self.request.user

class LicenseKeyActivateView(generics.GenericAPIView):
    serializer_class = LicenseKeyActivateSerializer
    permission_classes = [permissions.IsAuthenticated]

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
        license_obj.is_active = True
        license_obj.assigned_admin = admin
        license_obj.save()
        admin.license = license_obj
        admin.save()
        return Response({"message": "License activated successfully."}, status=status.HTTP_200_OK)

# --- NETWORK CREATION VIEWS ---

class SubAdminCreateView(generics.CreateAPIView):
    serializer_class = SubAdminCreateSerializer
    permission_classes = [permissions.IsAuthenticated, IsLicenseActive]

    def perform_create(self, serializer):
        creating_admin = self.request.user
        serializer.save(parent_admin_id=creating_admin, license=creating_admin.license)

    def get_serializer_context(self):
        return {'request': self.request}

class SubUserCreateView(generics.CreateAPIView):
    serializer_class = SubUserCreateSerializer
    permission_classes = [permissions.IsAuthenticated, IsLicenseActive]

    def perform_create(self, serializer):
        creating_admin = self.request.user
        serializer.save(parent_admin_id=creating_admin, license=creating_admin.license)

# --- FILTERED VIEWSETS (Correctly using the Mixin) ---

class AdminViewSet(LicenseScopeMixin, viewsets.ReadOnlyModelViewSet):
    serializer_class = AdminProfileSerializer
    permission_classes = [permissions.IsAuthenticated, IsLicenseActive]
    queryset = Admin.objects.all()

    def get_queryset(self):
        # The mixin provides the base queryset, already filtered by license.
        queryset = super().get_queryset()
        # We just add the extra hierarchy filtering.
        network_admin_ids = get_descendant_admin_ids(self.request.user)
        return queryset.filter(admin_id__in=network_admin_ids, layer__gt=self.request.user.layer)

class UserViewSet(LicenseScopeMixin, viewsets.ReadOnlyModelViewSet):
    serializer_class = UserDetailSerializer
    permission_classes = [permissions.IsAuthenticated, IsLicenseActive]
    queryset = User.objects.all()
    # No get_queryset override is needed; the LicenseScopeMixin does everything!

class ServerViewSet(viewsets.ModelViewSet):
    # This view does not use the mixin because its filtering logic is more complex.
    serializer_class = ServerSerializer
    permission_classes = [permissions.IsAuthenticated, IsLicenseActive]

    def get_queryset(self):
        user = self.request.user
        if not user.license:
            return Server.objects.none()
        admins_in_license = Admin.objects.filter(license=user.license)
        server_ids = admins_in_license.values_list('server_id', flat=True).distinct()
        return Server.objects.filter(server_id__in=server_ids)

class DeviceViewSet(viewsets.ModelViewSet):
    # This view also uses custom filtering logic.
    serializer_class = DeviceSerializer
    permission_classes = [permissions.IsAuthenticated, IsLicenseActive]

    def get_queryset(self):
        user = self.request.user
        if not user.license:
            return Device.objects.none()
        admins_in_license = Admin.objects.filter(license=user.license)
        server_ids = admins_in_license.values_list('server_id', flat=True).distinct()
        network_servers = Server.objects.filter(server_id__in=server_ids)
        return Device.objects.filter(server_id__in=network_servers)
    
class ProtectedView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response({"message": "You have access to this protected data!"})