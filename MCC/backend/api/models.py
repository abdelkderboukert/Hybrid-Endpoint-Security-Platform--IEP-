from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
import uuid
from django.contrib.auth.hashers import make_password, check_password
from django.utils import timezone
from .managers import AdminManager # Assuming you have this manager in a separate file

# ---
# 1. Admins Model
# ---

class Admin(AbstractBaseUser):
    admin_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    username = models.CharField(max_length=255, unique=True)
    email = models.EmailField(unique=True)
    parent_admin_id = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='children')
    layer = models.IntegerField(default=0)
    server_id = models.ForeignKey('Server', on_delete=models.CASCADE, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)
    last_login = models.DateTimeField(null=True, blank=True)
    date_joined = models.DateTimeField(auto_now_add=True)

    objects = AdminManager()

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email']

    class Meta:
        verbose_name = 'Admin'
        verbose_name_plural = 'Admins'

    def __str__(self):
        return self.username

    def has_perm(self, perm, obj=None):
        return self.is_superuser

    def has_module_perms(self, app_label):
        return self.is_superuser

# ---
# 2. Servers Model
# ---

class Server(models.Model):
    SERVER_TYPES = [
        ('Cloud', 'Cloud'),
        ('Local', 'Local'),
        ('Sub-Local', 'Sub-Local'),
    ]
    server_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    server_type = models.CharField(max_length=20, choices=SERVER_TYPES)
    parent_server_id = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='sub_servers')
    is_connected = models.BooleanField(default=False)
    last_heartbeat = models.DateTimeField(null=True, blank=True)
    licence_key = models.CharField(max_length=255, unique=True, null=True, blank=True)

    def __str__(self):
        return self.server_id

# ---
# 3. Devices Model
# ---

class Device(models.Model):
    device_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    device_name = models.CharField(max_length=255)
    os = models.CharField(max_length=255)
    server_id = models.ForeignKey('Server', on_delete=models.CASCADE)
    is_isolated = models.BooleanField(default=False)
    last_seen = models.DateTimeField(auto_now=True)
    current_logged_in_user_id = models.ForeignKey('User', on_delete=models.SET_NULL, null=True, blank=True)

    def __str__(self):
        return self.device_name

# ---
# 4. Users Model
# ---

class User(models.Model):
    user_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    username = models.CharField(max_length=255, unique=True)
    parent_admin_id = models.ForeignKey('Admin', on_delete=models.SET_NULL, null=True, blank=True)
    email = models.EmailField(unique=True)
    associated_device_ids = models.JSONField(default=list, blank=True)

    def __str__(self):
        return self.username

# ---
# 5. Policies Model
# ---

class Policy(models.Model):
    policy_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    policy_name = models.CharField(max_length=255)
    policy_json = models.JSONField()
    created_by_admin_id = models.ForeignKey('Admin', on_delete=models.SET_NULL, null=True, blank=True)
    applicable_layer = models.IntegerField()

    def __str__(self):
        return self.policy_name

# ---
# 6. Threats Model
# ---

class Threat(models.Model):
    STATUS_CHOICES = [
        ('Detected', 'Detected'),
        ('Quarantined', 'Quarantined'),
        ('Remediated', 'Remediated'),
    ]
    threat_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    threat_name = models.CharField(max_length=255)
    device_id = models.ForeignKey('Device', on_delete=models.CASCADE)
    detection_timestamp = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Detected')

    def __str__(self):
        return self.threat_name

# ---
# 7. User Photos Model
# ---

class UserPhoto(models.Model):
    photo_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user_id = models.ForeignKey('User', on_delete=models.CASCADE)
    device_id = models.ForeignKey('Device', on_delete=models.CASCADE)
    threat_id = models.ForeignKey('Threat', on_delete=models.SET_NULL, null=True, blank=True)
    photo_data = models.BinaryField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return str(self.photo_id)

# ---
# 8. Data Integrity Log Model
# ---

class DataIntegrityLog(models.Model):
    log_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    device_id = models.ForeignKey('Device', on_delete=models.CASCADE)
    file_path = models.TextField()
    data_hash = models.CharField(max_length=255)
    timestamp = models.DateTimeField(auto_now_add=True)
    previous_hash = models.CharField(max_length=255)

    def __str__(self):
        return str(self.log_id)