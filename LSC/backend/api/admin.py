# api/admin.py

from django.contrib import admin
from .models import (
    Admin,
    Server,
    Device,
    Group,
    User,
    Policy,
    Threat,
    UserPhoto,
    DataIntegrityLog,
    LicenseKey,
    SyncLog,
    BootstrapToken,
)

# Customize the admin interface for each model

@admin.register(Admin)
class AdminAdmin(admin.ModelAdmin):
    list_display = ('username', 'email', 'layer', 'is_active', 'license', 'server')
    list_filter = ('layer', 'is_active', 'date_joined')
    search_fields = ('username', 'email')
    readonly_fields = ('admin_id', 'date_joined', 'last_login')
    fieldsets = (
        ('Account Info', {'fields': ('username', 'email', 'password')}),
        ('Hierarchy & Permissions', {'fields': ('layer', 'parent_admin_id', 'is_staff', 'is_superuser', 'is_active')}),
        ('Associations', {'fields': ('license', 'server')}),
        ('Timestamps', {'fields': ('last_login', 'date_joined')}),
    )

@admin.register(Server)
class ServerAdmin(admin.ModelAdmin):
    list_display = ('server_name', 'hostname', 'server_type', 'ip_address', 'is_connected', 'owner_admin')
    list_filter = ('server_type', 'is_connected', 'os_name')
    search_fields = ('server_name', 'hostname', 'ip_address', 'mac_address')
    readonly_fields = ('server_id', 'api_key', 'detection_timestamp', 'last_info_update')

@admin.register(Device)
class DeviceAdmin(admin.ModelAdmin):
    list_display = ('device_name', 'os', 'server', 'is_isolated', 'last_seen')
    list_filter = ('is_isolated', 'os', 'device_type')
    search_fields = ('device_name', 'serial_number')
    readonly_fields = ('device_id',)

@admin.register(Group)
class GroupAdmin(admin.ModelAdmin):
    list_display = ('group_name', 'parent_admin_id', 'license')
    search_fields = ('group_name',)
    readonly_fields = ('group_id',)

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('username', 'email', 'parent_admin_id', 'license')
    search_fields = ('username', 'email')
    readonly_fields = ('user_id',)
    filter_horizontal = ('groups',)  # Provides a better UI for ManyToMany fields

@admin.register(Policy)
class PolicyAdmin(admin.ModelAdmin):
    list_display = ('policy_name', 'applicable_layer', 'created_by_admin_id')
    list_filter = ('applicable_layer',)
    search_fields = ('policy_name',)
    readonly_fields = ('policy_id',)

@admin.register(Threat)
class ThreatAdmin(admin.ModelAdmin):
    list_display = ('threat_name', 'device_id', 'status', 'detection_timestamp')
    list_filter = ('status',)
    search_fields = ('threat_name',)
    readonly_fields = ('threat_id', 'detection_timestamp')

@admin.register(UserPhoto)
class UserPhotoAdmin(admin.ModelAdmin):
    list_display = ('photo_id', 'user_id', 'device_id', 'timestamp')
    readonly_fields = ('photo_id', 'timestamp')

@admin.register(DataIntegrityLog)
class DataIntegrityLogAdmin(admin.ModelAdmin):
    list_display = ('log_id', 'device_id', 'file_path', 'timestamp')
    search_fields = ('file_path',)
    readonly_fields = ('log_id', 'timestamp')

@admin.register(LicenseKey)
class LicenseKeyAdmin(admin.ModelAdmin):
    list_display = ('key', 'is_active', 'assigned_admin', 'date_created')
    list_filter = ('is_active',)
    search_fields = ('key',)
    readonly_fields = ('id', 'date_created')

@admin.register(SyncLog)
class SyncLogAdmin(admin.ModelAdmin):
    list_display = ('admin', 'timestamp')
    list_filter = ('timestamp',)
    search_fields = ('admin__username',)
    readonly_fields = ('log_id', 'timestamp', 'admin', 'request_data')

@admin.register(BootstrapToken)
class BootstrapTokenAdmin(admin.ModelAdmin):
    list_display = ('token', 'created_by', 'is_used', 'date_created')
    list_filter = ('is_used',)
    search_fields = ('token', 'created_by__username')
    readonly_fields = ('id', 'token', 'date_created')