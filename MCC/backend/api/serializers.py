from rest_framework import serializers
from .models import Admin,User,Server, Device
from django.contrib.auth.password_validation import validate_password
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

class AdminRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password2 = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = Admin
        fields = ('username', 'email', 'password', 'password2')

    def validate(self, attrs):
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Password fields didn't match."})
        return attrs

    def create(self, validated_data):
        user = Admin.objects.create(
            username=validated_data['username'],
            email=validated_data['email']
        )
        user.set_password(validated_data['password'])
        user.save()
        return user

class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        # Add custom claims
        token['username'] = user.username
        token['email'] = user.email
        return token
    

class AdminDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = Admin
        # List the fields you want to send to the frontend
        fields = ['admin_id', 'username', 'email', 'date_joined', 'last_login']


class SubAdminCreateSerializer(serializers.ModelSerializer):
    """
    Serializer for creating a new Admin (sub-admin) by a parent admin.
    """
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password2 = serializers.CharField(write_only=True, required=True, label="Confirm Password")

    class Meta:
        model = Admin
        fields = ['username', 'email', 'layer', 'password', 'password2']

    def validate(self, attrs):
        # Check if passwords match
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Password fields didn't match."})

        # --- THIS IS THE UPDATED PERMISSION CHECK ---
        creating_admin = self.context['request'].user
        requested_layer = attrs.get('layer')

        # New Rule: New admin's layer must be exactly one level below the creator's.
        expected_layer = creating_admin.layer + 1
        if requested_layer != expected_layer:
            raise serializers.ValidationError({
                "layer": f"As a layer {creating_admin.layer} admin, you can only create layer {expected_layer} admins."
            })

        return attrs

    def create(self, validated_data):
        validated_data.pop('password2')
        new_admin = Admin.objects.create_user(**validated_data)
        return new_admin


class SubUserCreateSerializer(serializers.ModelSerializer):
    """
    Serializer for creating a new User by a logged-in admin.
    """
    class Meta:
        model = User
        # These are the fields the frontend will send when creating a user.
        fields = [
            'user_id',
            'username', 
            'email',
            'parent_admin_id',
            'associated_device_ids'
        ]
        # These fields are set automatically by the backend and are not required as input.
        # They will be included in the response after a successful creation.
        read_only_fields = ['user_id', 'parent_admin_id']


class ServerSerializer(serializers.ModelSerializer):
    """
    Serializer for the Server model.
    """
    class Meta:
        model = Server
        fields = '__all__' # This includes all fields from your Server model

class DeviceSerializer(serializers.ModelSerializer):
    """
    Serializer for the Device model.
    """
    class Meta:
        model = Device
        fields = '__all__'

class UserDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['user_id', 'username', 'email', 'parent_admin_id']

class AdminProfileSerializer(serializers.ModelSerializer):
    # Make the password write-only and not required for updates
    password = serializers.CharField(write_only=True, required=False, allow_blank=True)

    class Meta:
        model = Admin
        fields = [
            'admin_id', 
            'username', 
            'email', 
            'layer', 
            'date_joined', 
            'last_login',
            'password', # Include password for updates
        ]
        read_only_fields = ['admin_id', 'date_joined', 'last_login', 'layer']

    def update(self, instance, validated_data):
        # Handle password hashing if a new password is provided
        password = validated_data.pop('password', None)
        if password:
            instance.set_password(password)
        
        return super().update(instance, validated_data)
    

class LicenseKeyActivateSerializer(serializers.Serializer):
    key = serializers.CharField(required=True, write_only=True)