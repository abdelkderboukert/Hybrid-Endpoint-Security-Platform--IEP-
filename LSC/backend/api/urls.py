from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenBlacklistView

from .views import (
    AdminRegisterView,
    CustomLoginView,
    ServerHierarchyView,
    CustomTokenRefreshView,
    AdminProfileView,
    LicenseKeyActivateView,
    ServerDetectionAPIView,
    SubAdminCreateView,
    SubUserCreateView,
    AdminViewSet,
    UserViewSet,
    ServerViewSet,
    DeviceViewSet,
    MasterSyncAPIView,
    GroupViewSet,
    ServerRegistrationView # <-- NEW IMPORT
)

router = DefaultRouter()
router.register(r'servers', ServerViewSet, basename='server')
router.register(r'devices', DeviceViewSet, basename='device')
router.register(r'network/admins', AdminViewSet, basename='network-admin')
router.register(r'network/users', UserViewSet, basename='network-user')
router.register(r'network/groups', GroupViewSet, basename='group')


urlpatterns = [
    # --- NEW ENDPOINT ---
    path('server/register/', ServerRegistrationView.as_view(), name='server-register'),
    
    path('servers/hierarchy/', ServerHierarchyView.as_view(), name='server-hierarchy'),
    path('server/detect/', ServerDetectionAPIView.as_view(), name='server-detect'),

    path('', include(router.urls)),
    
    path('sync/', MasterSyncAPIView.as_view(), name='master-sync'),
    
    path('register/', AdminRegisterView.as_view(), name='register'),
    path('login/', CustomLoginView.as_view(), name='login'),
    path('logout/', TokenBlacklistView.as_view(), name='token_blacklist'),
    path('token/refresh/', CustomTokenRefreshView.as_view(), name='token_refresh'),
    
    path('profile/', AdminProfileView.as_view(), name='profile'),
    path('license/activate/', LicenseKeyActivateView.as_view(), name='license_activate'),

    path('network/admins-create/', SubAdminCreateView.as_view(), name='create_sub_admin'),
    path('network/users-create/', SubUserCreateView.as_view(), name='create_sub_user'),
]