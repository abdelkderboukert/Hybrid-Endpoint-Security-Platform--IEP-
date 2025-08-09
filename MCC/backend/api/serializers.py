from rest_framework import serializers
from .models import Admin
from django.contrib.auth import authenticate

class AdminSerializer(serializers.ModelSerializer):
    class Meta:
        model = Admin
        fields = ['admin_id', 'username', 'email', 'layer', 'is_active']

class RegisterAdminSerializer(serializers.ModelSerializer):
    class Meta:
        model = Admin
        fields = ['username', 'email', 'password']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = Admin.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password']
        )
        return user

class LoginAdminSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)
    password = serializers.CharField(write_only=True)
    
    def validate(self, data):
        # Authenticate using email since USERNAME_FIELD is 'username' but login is via email
        user = Admin.objects.get(email=data['email'])
        if user and user.check_password(data['password']):
            if user.is_active:
                return user
        raise serializers.ValidationError("Incorrect credentials!")