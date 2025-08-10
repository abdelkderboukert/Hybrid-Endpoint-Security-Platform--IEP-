from django.urls import path
from .views import (
    AdminInfoView, 
    AdminRegisterView, 
    LoginView, 
    LogoutView, 
    CookieTokenRefreshView
)

urlpatterns = [
    path('register/', AdminRegisterView.as_view(), name='register-admin'),
    path('login/', LoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),
    path('user-info/', AdminInfoView.as_view(), name='admin-info'),
    path('token/refresh/', CookieTokenRefreshView.as_view(), name='token-refresh'),
]