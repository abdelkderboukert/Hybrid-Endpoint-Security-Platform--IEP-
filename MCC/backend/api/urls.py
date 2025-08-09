from django.urls import path
from .views import *

urlpatterns = [
    path("users/user-info/", UserInfoView.as_view(), name="info-user"),
    path("users/register/", UserRegisterView.as_view(), name="register-user"),
    path("users/login/", LoginView.as_view(), name="user-login"),
    path("users/logout/", LogoutView.as_view(), name="user-logout"),
    path("refresh/", CookieTokenRefreshView.as_view(), name="token-refresh"),
]
