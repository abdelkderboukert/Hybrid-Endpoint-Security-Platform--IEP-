# from rest_framework import serializers
# from .models import Admin, User, Device, Server, Policy, Threat, UserPhoto, DataIntegrityLog, LicenseKey, SyncLog
# from django.contrib.auth.password_validation import validate_password
# from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

# MODEL_MAP = {
#     'Admin': Admin,
#     'User': User,
#     'Device': Device,
#     'Server': Server,
#     'Policy': Policy,
#     'Threat': Threat,
#     'UserPhoto': UserPhoto,
#     'DataIntegrityLog': DataIntegrityLog,
#     'LicenseKey': LicenseKey,
#     'SyncLog': SyncLog,
# }

# class SyncItemSerializer(serializers.Serializer):
#     model_name = serializers.CharField()
#     data = serializers.JSONField()
#     action = serializers.CharField()
#     temp_id = serializers.UUIDField(required=False, allow_null=True)
#     client_last_modified = serializers.DateTimeField(required=False, allow_null=True)

#     def validate_model_name(self, value):
#         if value not in MODEL_MAP:
#             raise serializers.ValidationError("Invalid model name.")
#         return value

# class SyncLogSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = SyncLog
#         fields = '__all__'

# # Standard API serializers
# class AdminRegisterSerializer(serializers.ModelSerializer):
#     password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
#     password2 = serializers.CharField(write_only=True, required=True)

#     class Meta:
#         model = Admin
#         fields = ('username', 'email', 'password', 'password2')

#     def validate(self, attrs):
#         if attrs['password'] != attrs['password2']:
#             raise serializers.ValidationError({"password": "Password fields didn't match."})
#         return attrs

#     def create(self, validated_data):
#         validated_data.pop('password2')
#         user = Admin.objects.create_user(**validated_data)
#         user.set_password(validated_data['password'])
#         user.save()
#         return user

# class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
#     @classmethod
#     def get_token(cls, user):
#         token = super().get_token(user)
#         token['username'] = user.username
#         token['email'] = user.email
#         return token
    
# class AdminDetailSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Admin
#         fields = ['admin_id', 'username', 'email', 'date_joined', 'last_login']

# class SubAdminCreateSerializer(serializers.ModelSerializer):
#     password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
#     password2 = serializers.CharField(write_only=True, required=True, label="Confirm Password")

#     class Meta:
#         model = Admin
#         fields = ['username', 'email', 'layer', 'password', 'password2']

#     def validate(self, attrs):
#         if attrs['password'] != attrs['password2']:
#             raise serializers.ValidationError({"password": "Password fields didn't match."})
        
#         creating_admin = self.context['request'].user
#         requested_layer = attrs.get('layer')

#         expected_layer = creating_admin.layer + 1
#         if requested_layer != expected_layer:
#             raise serializers.ValidationError({"layer": f"As a layer {creating_admin.layer} admin, you can only create layer {expected_layer} admins."})

#         return attrs

#     def create(self, validated_data):
#         validated_data.pop('password2')
#         new_admin = Admin.objects.create_user(**validated_data)
#         return new_admin

# class SubUserCreateSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = User
#         fields = ['user_id', 'username', 'email', 'parent_admin_id', 'associated_device_ids']
#         read_only_fields = ['user_id', 'parent_admin_id']

# class ServerSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Server
#         fields = '__all__'

# class DeviceSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Device
#         fields = '__all__'

# class UserDetailSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = User
#         fields = ['user_id', 'username', 'email', 'parent_admin_id']

# class AdminProfileSerializer(serializers.ModelSerializer):
#     password = serializers.CharField(write_only=True, required=False, allow_blank=True)

#     class Meta:
#         model = Admin
#         fields = ['admin_id', 'username', 'email', 'layer', 'date_joined', 'last_login', 'password']
#         read_only_fields = ['admin_id', 'date_joined', 'last_login', 'layer']

#     def update(self, instance, validated_data):
#         password = validated_data.pop('password', None)
#         if password:
#             instance.set_password(password)
        
#         return super().update(instance, validated_data)

# class LicenseKeyActivateSerializer(serializers.Serializer):
#     key = serializers.CharField(required=True, write_only=True)

# serliazer.py
from rest_framework import serializers
from .models import Admin, User, Device, Server, Policy, Threat, UserPhoto, DataIntegrityLog, LicenseKey, SyncLog, Group
from django.contrib.auth.password_validation import validate_password
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

MODEL_MAP = {
    'Admin': Admin,
    'User': User,
    'Device': Device,
    'Server': Server,
    'Policy': Policy,
    'Threat': Threat,
    'UserPhoto': UserPhoto,
    'DataIntegrityLog': DataIntegrityLog,
    'LicenseKey': LicenseKey,
    'SyncLog': SyncLog,
    'Group': Group,
}

class SyncItemSerializer(serializers.Serializer):
    model_name = serializers.CharField()
    data = serializers.JSONField()
    action = serializers.CharField()
    temp_id = serializers.UUIDField(required=False, allow_null=True)
    client_last_modified = serializers.DateTimeField(required=False, allow_null=True)

    def validate_model_name(self, value):
        if value not in MODEL_MAP:
            raise serializers.ValidationError("Invalid model name.")
        return value

class SyncLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = SyncLog
        fields = '__all__'

# Standard API serializers
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
        validated_data.pop('password2')
        user = Admin.objects.create_user(**validated_data)
        user.set_password(validated_data['password'])
        user.save()
        return user

class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['username'] = user.username
        token['email'] = user.email
        return token
    
class AdminDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = Admin
        fields = ['admin_id', 'username', 'email', 'date_joined', 'last_login']

class SubAdminCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password2 = serializers.CharField(write_only=True, required=True, label="Confirm Password")

    class Meta:
        model = Admin
        fields = ['username', 'email', 'layer', 'password', 'password2']

    def validate(self, attrs):
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Password fields didn't match."})
        
        creating_admin = self.context['request'].user
        requested_layer = attrs.get('layer')

        expected_layer = creating_admin.layer + 1
        if requested_layer != expected_layer:
            raise serializers.ValidationError({"layer": f"As a layer {creating_admin.layer} admin, you can only create layer {expected_layer} admins."})

        return attrs

    def create(self, validated_data):
        validated_data.pop('password2')
        new_admin = Admin.objects.create_user(**validated_data)
        return new_admin

class SubUserCreateSerializer(serializers.ModelSerializer):
    """
    Serializer for creating a new User.
    Updated to accept a list of groups.
    """
    groups = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=Group.objects.all(),
        required=False,
        help_text="A list of group UUIDs to add the user to."
    )

    class Meta:
        model = User
        fields = ['user_id', 'username', 'email', 'parent_admin_id', 'associated_device_ids', 'groups']
        read_only_fields = ['user_id', 'parent_admin_id']

    def create(self, validated_data):
        groups_data = validated_data.pop('groups', [])
        user = User.objects.create(**validated_data)
        user.groups.set(groups_data)
        return user


class GroupSerializer(serializers.ModelSerializer):
    class Meta:
        model = Group
        fields = '__all__'
        read_only_fields = ['group_id','parent_admin_id']

class ServerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Server
        fields = '__all__'

class DeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Device
        fields = '__all__'

class UserDetailSerializer(serializers.ModelSerializer):
    """
    Serializer for retrieving and updating user details.
    Allows manipulation of the user's group memberships.
    """
    groups = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=Group.objects.all(),
        required=False  # Make this field optional for updates
    )
    
    class Meta:
        model = User
        fields = ['user_id', 'username', 'email', 'parent_admin_id', 'groups']
        read_only_fields = ['user_id', 'parent_admin_id']

    def update(self, instance, validated_data):
        # Handle the many-to-many relationship for groups
        groups_data = validated_data.pop('groups', None)

        # Update the user's other fields
        instance = super().update(instance, validated_data)

        if groups_data is not None:
            instance.groups.set(groups_data)  # .set() method handles adding/removing groups
        
        return instance

class AdminProfileSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False, allow_blank=True)

    class Meta:
        model = Admin
        fields = ['admin_id', 'username', 'email', 'layer', 'date_joined', 'last_login', 'password']
        read_only_fields = ['admin_id', 'date_joined', 'last_login', 'layer']

    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)
        if password:
            instance.set_password(password)
        
        return super().update(instance, validated_data)

class LicenseKeyActivateSerializer(serializers.Serializer):
    key = serializers.CharField(required=True, write_only=True)