from django.contrib import admin
from .models import Admin, Server, Device, User, Policy, Threat, UserPhoto, DataIntegrityLog

@admin.register(Admin)
class AdminAdmin(admin.ModelAdmin):
    list_display = ('admin_id', 'username', 'email', 'layer', 'is_staff', 'is_active')
    search_fields = ('username', 'email')
    list_filter = ('is_staff', 'is_active', 'layer')
    ordering = ('username',)

    fieldsets = (
        (None, {
            'fields': ('username', 'email', 'password')
        }),
        ('Hierarchy Info', {
            'fields': ('parent_admin_id', 'layer', 'server_id')
        }),
        ('Permissions', {
            'fields': ('is_staff', 'is_active', 'is_superuser')
        }),
    )

    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'email', 'password')
        }),
    )

@admin.register(Server)
class ServerAdmin(admin.ModelAdmin):
    list_display = ('server_id', 'server_type', 'is_connected', 'parent_server_id', 'licence_key')
    search_fields = ('server_id', 'licence_key')
    list_filter = ('server_type', 'is_connected')

@admin.register(Device)
class DeviceAdmin(admin.ModelAdmin):
    list_display = ('device_id', 'device_name', 'os', 'server_id', 'is_isolated', 'last_seen')
    search_fields = ('device_name', 'os')
    list_filter = ('is_isolated', 'os')

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('user_id', 'username', 'email', 'parent_admin_id')
    search_fields = ('username', 'email')

@admin.register(Policy)
class PolicyAdmin(admin.ModelAdmin):
    list_display = ('policy_id', 'policy_name', 'created_by_admin_id', 'applicable_layer')
    search_fields = ('policy_name',)
    list_filter = ('applicable_layer',)

@admin.register(Threat)
class ThreatAdmin(admin.ModelAdmin):
    list_display = ('threat_id', 'threat_name', 'device_id', 'detection_timestamp', 'status')
    search_fields = ('threat_name',)
    list_filter = ('status',)

@admin.register(UserPhoto)
class UserPhotoAdmin(admin.ModelAdmin):
    list_display = ('photo_id', 'user_id', 'device_id', 'threat_id', 'timestamp')
    search_fields = ('user_id__username', 'device_id__device_name')

@admin.register(DataIntegrityLog)
class DataIntegrityLogAdmin(admin.ModelAdmin):
    list_display = ('log_id', 'device_id', 'file_path', 'timestamp')
    search_fields = ('file_path',)