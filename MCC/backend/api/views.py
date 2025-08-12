# api/views.py

from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from .serializers import AdminRegisterSerializer, AdminDetailSerializer
from dj_rest_auth.views import LoginView, LogoutView
from .serializers import MyTokenObtainPairSerializer
from rest_framework_simplejwt.views import TokenObtainPairView
from .models import Admin

from django.conf import settings

# Using a custom view to integrate our custom serializer
# class CustomLoginView(TokenObtainPairView):
#     serializer_class = MyTokenObtainPairSerializer

#     def post(self, request, *args, **kwargs):
#         response = super().post(request, *args, **kwargs)
#         if response.status_code == 200:
#             access_token = response.data.get('access')
#             refresh_token = response.data.get('refresh')
            
#             # Manually set HttpOnly cookies
#             res = Response(response.data, status=status.HTTP_200_OK)
#             res.set_cookie(
#                 key='access_token',
#                 value=access_token,
#                 httponly=True,
#                 samesite='Lax', # or 'Strict'
#                 # secure=True # Use in production with HTTPS
#             )
#             res.set_cookie(
#                 key='refresh_token',
#                 value=refresh_token,
#                 httponly=True,
#                 samesite='Lax', # or 'Strict'
#                 # secure=True # Use in production with HTTPS
#                 path='/',
#                 domain=None,  # Set to your domain if needed
#             )
#             return res
#         return response

class CustomLoginView(TokenObtainPairView):
    serializer_class = MyTokenObtainPairSerializer

    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        if response.status_code == 200:
            access_token = response.data.get('access')
            refresh_token = response.data.get('refresh')
            
            res = Response(response.data, status=status.HTTP_200_OK)
            
            # Get token lifetimes from settings
            access_token_lifetime = settings.SIMPLE_JWT['ACCESS_TOKEN_LIFETIME']
            refresh_token_lifetime = settings.SIMPLE_JWT['REFRESH_TOKEN_LIFETIME']
            
            res.set_cookie(
                key='access_token',
                value=access_token,
                httponly=True,
                samesite='Lax',
                secure=False,
                path='/',
                max_age=access_token_lifetime.total_seconds() # THE FIX
            )
            res.set_cookie(
                key='refresh_token',
                value=refresh_token,
                httponly=True,
                samesite='Lax',
                secure=False,
                path='/',
                max_age=refresh_token_lifetime.total_seconds() # THE FIX
            )
            return res
        return response
    
class AdminRegisterView(generics.CreateAPIView):
    queryset = Admin.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = AdminRegisterSerializer


class CustomLogoutView(LogoutView):
    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        # Clear the HttpOnly cookies on logout
        response.delete_cookie('access_token')
        response.delete_cookie('refresh_token')
        return response

# Example protected view
class ProtectedView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response({"message": "You have access to this protected data!"})
    

class AdminDetailView(generics.RetrieveAPIView):
    """
    Returns the details of the currently authenticated admin.
    """
    serializer_class = AdminDetailSerializer
    permission_classes = [IsAuthenticated] # Ensures only logged-in users can access it

    def get_object(self):
        # request.user is automatically populated by Django/DRF
        # after authenticating the request via the access_token cookie.
        return self.request.user