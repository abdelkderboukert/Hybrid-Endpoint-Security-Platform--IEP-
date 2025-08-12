from django.urls import path
from api.views import AdminRegisterView, CustomLoginView, CustomLogoutView, ProtectedView, AdminDetailView
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('register/', AdminRegisterView.as_view(), name='auth_register'),
    path('login/', CustomLoginView.as_view(), name='auth_login'),
    path('logout/', CustomLogoutView.as_view(), name='auth_logout'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('admins/me/', AdminDetailView.as_view(), name='admin_me'),
    path('protected/', ProtectedView.as_view(), name='protected'),
]