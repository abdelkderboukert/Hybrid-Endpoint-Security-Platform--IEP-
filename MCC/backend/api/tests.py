from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient
from .models import Admin
import json

class AdminAuthTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.register_url = reverse('register-admin')
        self.login_url = reverse('login')
        self.logout_url = reverse('logout')
        self.refresh_url = reverse('token-refresh')
        self.user_info_url = reverse('user-info')

        self.user_data = {
            'username': 'testuser',
            'email': 'testuser@example.com',
            'password': 'strongpassword123'
        }
        self.admin_user = Admin.objects.create_user(**self.user_data)
    
    def test_admin_registration(self):
        """
        Test that a new admin can be registered successfully.
        """
        new_user_data = {
            'username': 'newuser',
            'email': 'newuser@example.com',
            'password': 'anothersafepassword'
        }
        response = self.client.post(self.register_url, new_user_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(Admin.objects.filter(email='newuser@example.com').exists())

    def test_admin_login_success(self):
        """
        Test that an existing admin can log in successfully.
        """
        login_data = {
            'email': 'testuser@example.com',
            'password': 'strongpassword123'
        }
        response = self.client.post(self.login_url, login_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access_token', response.cookies)
        self.assertIn('refresh_token', response.cookies)
    
    def test_admin_login_failure(self):
        """
        Test that login fails with incorrect credentials.
        """
        login_data = {
            'email': 'testuser@example.com',
            'password': 'wrongpassword'
        }
        response = self.client.post(self.login_url, login_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertNotIn('access_token', response.cookies)

    def test_admin_logout_success(self):
        """
        Test that an admin can log out successfully.
        """
        login_data = {
            'email': 'testuser@example.com',
            'password': 'strongpassword123'
        }
        login_response = self.client.post(self.login_url, login_data, format='json')
        refresh_token = login_response.cookies['refresh_token'].value
        self.client.cookies['refresh_token'] = refresh_token

        logout_response = self.client.post(self.logout_url)
        self.assertEqual(logout_response.status_code, status.HTTP_200_OK)
        self.assertNotIn('access_token', logout_response.cookies)
        self.assertNotIn('refresh_token', logout_response.cookies)

    def test_token_refresh(self):
        """
        Test that a new access token can be obtained using the refresh token.
        """
        login_data = {
            'email': 'testuser@example.com',
            'password': 'strongpassword123'
        }
        login_response = self.client.post(self.login_url, login_data, format='json')
        self.client.cookies['refresh_token'] = login_response.cookies['refresh_token'].value
        
        refresh_response = self.client.post(self.refresh_url)
        self.assertEqual(refresh_response.status_code, status.HTTP_200_OK)
        self.assertIn('access_token', refresh_response.cookies)
        self.assertNotEqual(refresh_response.cookies['access_token'].value, login_response.cookies['access_token'].value)

    def test_user_info_authenticated(self):
        """
        Test that authenticated users can retrieve their information.
        """
        login_data = {
            'email': 'testuser@example.com',
            'password': 'strongpassword123'
        }
        login_response = self.client.post(self.login_url, login_data, format='json')
        access_token = login_response.cookies['access_token'].value
        
        self.client.cookies['access_token'] = access_token
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')
        
        info_response = self.client.get(self.user_info_url)
        self.assertEqual(info_response.status_code, status.HTTP_200_OK)
        self.assertEqual(info_response.data['email'], self.user_data['email'])

    def test_user_info_unauthenticated(self):
        """
        Test that unauthenticated users cannot retrieve user information.
        """
        response = self.client.get(self.user_info_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)