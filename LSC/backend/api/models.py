from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
import uuid
from django.utils import timezone

# Assuming you have this manager in a separate file
from .managers import AdminManager 

# --- Abstract Base Classes for Synchronization ---
class SyncableModel(models.Model):
    last_modified = models.DateTimeField(auto_now=True)
    last_modified_by = models.UUIDField(null=True, blank=True, help_text="ID of the user or admin who made the change.")
    source_device_id = models.UUIDField(null=True, blank=True, help_text="ID of the device the change originated from.")
    version = models.IntegerField(default=1)

    class Meta:
        abstract = True

class HierarchicalModel(models.Model):
    parent_id = models.UUIDField(null=True, blank=True)

    class Meta:
        abstract = True
# --- End of Abstract Base Classes ---

# ---
# 1. Admins Model
# ---

class Admin(AbstractBaseUser, SyncableModel, HierarchicalModel):
    admin_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    username = models.CharField(max_length=255, unique=True)
    email = models.EmailField(unique=True)
    parent_admin_id = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='children')
    layer = models.IntegerField(default=0)
    license = models.ForeignKey('LicenseKey', on_delete=models.CASCADE, null=True, blank=True, related_name='admins')
    server = models.ForeignKey('Server', on_delete=models.CASCADE, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)
    last_login = models.DateTimeField(null=True, blank=True)
    date_joined = models.DateTimeField(auto_now_add=True)
    
    # You will need to create a custom AdminManager
    objects = AdminManager() 

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email']

    def __str__(self):
        return self.username

# ---
# 2. Enhanced Servers Model with detailed system information
# ---

class Server(SyncableModel): 
    SERVER_TYPES = [
        ('Cloud', 'Cloud'),
        ('Local', 'Local'),
        ('Sub-Local', 'Sub-Local'),
    ]
    
    server_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    server_type = models.CharField(max_length=20, choices=SERVER_TYPES)
    parent_server = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='sub_servers')
    is_connected = models.BooleanField(default=False)
    last_heartbeat = models.DateTimeField(null=True, blank=True)
    licence_key = models.CharField(max_length=255, unique=True, null=True, blank=True)
    
    # Enhanced server information
    server_name = models.CharField(max_length=255, blank=True, help_text="Computer/Server name")
    hostname = models.CharField(max_length=255, blank=True)
    domain = models.CharField(max_length=255, blank=True, help_text="Windows domain if applicable")
    workgroup = models.CharField(max_length=255, blank=True, help_text="Windows workgroup if applicable")
    
    # Operating System Information
    os_name = models.CharField(max_length=255, blank=True, help_text="e.g., Windows 11, Ubuntu 22.04")
    os_version = models.CharField(max_length=255, blank=True)
    os_architecture = models.CharField(max_length=50, blank=True, help_text="e.g., x64, x86")
    os_build = models.CharField(max_length=100, blank=True)
    
    # Hardware Information
    cpu_info = models.TextField(blank=True, help_text="CPU details")
    total_ram_gb = models.FloatField(null=True, blank=True, help_text="Total RAM in GB")
    available_storage_gb = models.FloatField(null=True, blank=True, help_text="Available storage in GB")
    
    # Network Information
    ip_address = models.GenericIPAddressField(null=True, blank=True, help_text="Primary IP address")
    mac_address = models.CharField(max_length=17, blank=True, help_text="Primary MAC address")
    network_interfaces = models.JSONField(default=list, blank=True, help_text="List of network interfaces")
    dns_servers = models.JSONField(default=list, blank=True, help_text="List of DNS servers")
    default_gateway = models.GenericIPAddressField(null=True, blank=True)
    
    # Current logged in user info
    current_user = models.CharField(max_length=255, blank=True, help_text="Current Windows user")
    user_profile_path = models.CharField(max_length=500, blank=True)
    is_admin_user = models.BooleanField(default=False, help_text="Is current user admin")
    
    # Security and Status
    antivirus_status = models.CharField(max_length=255, blank=True)
    firewall_status = models.CharField(max_length=255, blank=True)
    last_boot_time = models.DateTimeField(null=True, blank=True)
    uptime_hours = models.FloatField(null=True, blank=True)

    owner_admin = models.ForeignKey('Admin', on_delete=models.SET_NULL, null=True, blank=True, related_name='servers')
    
    # Auto-detection metadata
    auto_detected = models.BooleanField(default=False, help_text="Was this server auto-detected")
    detection_timestamp = models.DateTimeField(auto_now_add=True)
    last_info_update = models.DateTimeField(auto_now=True)
    
    class Meta:
        indexes = [
            models.Index(fields=['hostname']),
            models.Index(fields=['ip_address']),
            models.Index(fields=['mac_address']),
        ]
    
    def __str__(self):
        return f"{self.server_name or self.hostname or str(self.server_id)}"

# ---
# 3. Enhanced Devices Model
# ---

class Device(SyncableModel):
    device_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    device_name = models.CharField(max_length=255)
    os = models.CharField(max_length=255)
    server = models.ForeignKey('Server', on_delete=models.CASCADE)
    is_isolated = models.BooleanField(default=False)
    last_seen = models.DateTimeField(auto_now=True)
    current_logged_in_user_id = models.UUIDField(null=True, blank=True)
    
    # Enhanced device information
    device_type = models.CharField(max_length=100, blank=True, help_text="Desktop, Laptop, Server, etc.")
    manufacturer = models.CharField(max_length=255, blank=True)
    model = models.CharField(max_length=255, blank=True)
    serial_number = models.CharField(max_length=255, blank=True)
    
    # Hardware specs
    processor = models.CharField(max_length=255, blank=True)
    ram_gb = models.FloatField(null=True, blank=True)
    storage_gb = models.FloatField(null=True, blank=True)
    
    # Network info specific to device
    ip_addresses = models.JSONField(default=list, blank=True)
    mac_addresses = models.JSONField(default=list, blank=True)

    def __str__(self):
        return self.device_name
# ---
# 4. Users Model
# ---

class User(SyncableModel, HierarchicalModel):
    user_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    username = models.CharField(max_length=255, unique=True)
    parent_admin_id = models.ForeignKey('Admin', on_delete=models.SET_NULL, null=True, blank=True)
    email = models.EmailField(unique=True)
    associated_device_ids = models.JSONField(default=list, blank=True)
    license = models.ForeignKey('LicenseKey', on_delete=models.CASCADE, null=True, blank=True, related_name='users')

    def __str__(self):
        return self.username

# ---
# 5. Policies Model
# ---

class Policy(SyncableModel):
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

class Threat(SyncableModel):
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

class UserPhoto(SyncableModel):
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

class DataIntegrityLog(SyncableModel):
    log_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    device_id = models.ForeignKey('Device', on_delete=models.CASCADE)
    file_path = models.TextField()
    data_hash = models.CharField(max_length=255)
    timestamp = models.DateTimeField(auto_now_add=True)
    previous_hash = models.CharField(max_length=255)

    def __str__(self):
        return str(self.log_id)
        
# ---
# 9. LicenseKey Model
# ---

class LicenseKey(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    key = models.CharField(max_length=255, unique=True)
    is_active = models.BooleanField(default=False)
    assigned_admin = models.OneToOneField('Admin', on_delete=models.SET_NULL, null=True, blank=True, related_name='assigned_license')
    date_created = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.key

# --- New Sync Log Model ---
class SyncLog(models.Model):
    log_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    admin = models.ForeignKey('Admin', on_delete=models.SET_NULL, null=True, blank=True)
    timestamp = models.DateTimeField(auto_now_add=True)
    request_data = models.JSONField(help_text="The raw JSON of the sync request from the client.")
    
    def __str__(self):
        return f"Sync log from {self.admin.username} at {self.timestamp.isoformat()}"