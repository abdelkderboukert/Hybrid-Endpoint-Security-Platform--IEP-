// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncableModel _$SyncableModelFromJson(Map<String, dynamic> json) =>
    SyncableModel(
      lastModified: fromUtcIso8601String(json['last_modified'] as String?),
      lastModifiedBy: json['last_modified_by'] as String?,
      sourceDeviceId: json['source_device_id'] as String?,
      version: (json['version'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SyncableModelToJson(SyncableModel instance) =>
    <String, dynamic>{
      'last_modified': toUtcIso8601String(instance.lastModified),
      'last_modified_by': instance.lastModifiedBy,
      'source_device_id': instance.sourceDeviceId,
      'version': instance.version,
    };

Admin _$AdminFromJson(Map<String, dynamic> json) =>
    Admin(
        adminId: json['admin_id'] as String?,
        username: json['username'] as String?,
        email: json['email'] as String?,
        parentAdminId: json['parent_admin_id'] as String?,
        layer: (json['layer'] as num?)?.toInt(),
        license: json['license'] as String?,
        server: json['server'] as String?,
        isActive: json['is_active'] as bool?,
        isStaff: json['is_staff'] as bool?,
        isSuperuser: json['is_superuser'] as bool?,
        lastLogin: fromUtcIso8601String(json['last_login'] as String?),
        dateJoined: fromUtcIso8601String(json['date_joined'] as String?),
      )
      ..lastModified = fromUtcIso8601String(json['last_modified'] as String?)
      ..lastModifiedBy = json['last_modified_by'] as String?
      ..sourceDeviceId = json['source_device_id'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$AdminToJson(Admin instance) => <String, dynamic>{
  'last_modified': toUtcIso8601String(instance.lastModified),
  'last_modified_by': instance.lastModifiedBy,
  'source_device_id': instance.sourceDeviceId,
  'version': instance.version,
  'admin_id': instance.adminId,
  'username': instance.username,
  'email': instance.email,
  'parent_admin_id': instance.parentAdminId,
  'layer': instance.layer,
  'license': instance.license,
  'server': instance.server,
  'is_active': instance.isActive,
  'is_staff': instance.isStaff,
  'is_superuser': instance.isSuperuser,
  'last_login': toUtcIso8601String(instance.lastLogin),
  'date_joined': toUtcIso8601String(instance.dateJoined),
};

Server _$ServerFromJson(Map<String, dynamic> json) =>
    Server(
        serverId: json['server_id'] as String?,
        serverType: json['server_type'] as String?,
        parentServer: json['parent_server'] as String?,
        isConnected: json['is_connected'] as bool?,
        lastHeartbeat: fromUtcIso8601String(json['last_heartbeat'] as String?),
        licenceKey: json['licence_key'] as String?,
        ownerAdmin: json['owner_admin'] as String?,
        serverName: json['server_name'] as String?,
        hostname: json['hostname'] as String?,
        domain: json['domain'] as String?,
        workgroup: json['workgroup'] as String?,
        osName: json['os_name'] as String?,
        osVersion: json['os_version'] as String?,
        osArchitecture: json['os_architecture'] as String?,
        osBuild: json['os_build'] as String?,
        cpuInfo: json['cpu_info'] as String?,
        totalRamGb: (json['total_ram_gb'] as num?)?.toDouble(),
        availableStorageGb: (json['available_storage_gb'] as num?)?.toDouble(),
        ipAddress: json['ip_address'] as String?,
        macAddress: json['mac_address'] as String?,
        networkInterfaces: json['network_interfaces'] as List<dynamic>?,
        dnsServers: json['dns_servers'] as List<dynamic>?,
        defaultGateway: json['default_gateway'] as String?,
        currentUser: json['current_user'] as String?,
        userProfilePath: json['user_profile_path'] as String?,
        isUserAdmin: json['is_admin_user'] as bool?,
        antivirusStatus: json['antivirus_status'] as String?,
        firewallStatus: json['firewall_status'] as String?,
        lastBootTime: fromUtcIso8601String(json['last_boot_time'] as String?),
        uptimeHours: (json['uptime_hours'] as num?)?.toDouble(),
        autoDetected: json['auto_detected'] as bool?,
        detectionTimestamp: fromUtcIso8601String(
          json['detection_timestamp'] as String?,
        ),
        lastInfoUpdate: fromUtcIso8601String(
          json['last_info_update'] as String?,
        ),
      )
      ..lastModified = fromUtcIso8601String(json['last_modified'] as String?)
      ..lastModifiedBy = json['last_modified_by'] as String?
      ..sourceDeviceId = json['source_device_id'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$ServerToJson(Server instance) => <String, dynamic>{
  'last_modified': toUtcIso8601String(instance.lastModified),
  'last_modified_by': instance.lastModifiedBy,
  'source_device_id': instance.sourceDeviceId,
  'version': instance.version,
  'server_id': instance.serverId,
  'server_type': instance.serverType,
  'parent_server': instance.parentServer,
  'is_connected': instance.isConnected,
  'last_heartbeat': toUtcIso8601String(instance.lastHeartbeat),
  'licence_key': instance.licenceKey,
  'owner_admin': instance.ownerAdmin,
  'server_name': instance.serverName,
  'hostname': instance.hostname,
  'domain': instance.domain,
  'workgroup': instance.workgroup,
  'os_name': instance.osName,
  'os_version': instance.osVersion,
  'os_architecture': instance.osArchitecture,
  'os_build': instance.osBuild,
  'cpu_info': instance.cpuInfo,
  'total_ram_gb': instance.totalRamGb,
  'available_storage_gb': instance.availableStorageGb,
  'ip_address': instance.ipAddress,
  'mac_address': instance.macAddress,
  'network_interfaces': instance.networkInterfaces,
  'dns_servers': instance.dnsServers,
  'default_gateway': instance.defaultGateway,
  'current_user': instance.currentUser,
  'user_profile_path': instance.userProfilePath,
  'is_admin_user': instance.isUserAdmin,
  'antivirus_status': instance.antivirusStatus,
  'firewall_status': instance.firewallStatus,
  'last_boot_time': toUtcIso8601String(instance.lastBootTime),
  'uptime_hours': instance.uptimeHours,
  'auto_detected': instance.autoDetected,
  'detection_timestamp': toUtcIso8601String(instance.detectionTimestamp),
  'last_info_update': toUtcIso8601String(instance.lastInfoUpdate),
};

Device _$DeviceFromJson(Map<String, dynamic> json) =>
    Device(
        deviceId: json['device_id'] as String?,
        deviceName: json['device_name'] as String?,
        os: json['os'] as String?,
        server: json['server'] as String?,
        isIsolated: json['is_isolated'] as bool?,
        lastSeen: fromUtcIso8601String(json['last_seen'] as String?),
        currentLoggedInUserId: json['current_logged_in_user_id'] as String?,
        deviceType: json['device_type'] as String?,
        manufacturer: json['manufacturer'] as String?,
        model: json['model'] as String?,
        serialNumber: json['serial_number'] as String?,
        processor: json['processor'] as String?,
        ramGb: (json['ram_gb'] as num?)?.toDouble(),
        storageGb: (json['storage_gb'] as num?)?.toDouble(),
        ipAddresses: json['ip_addresses'] as List<dynamic>?,
        macAddresses: json['mac_addresses'] as List<dynamic>?,
      )
      ..lastModified = fromUtcIso8601String(json['last_modified'] as String?)
      ..lastModifiedBy = json['last_modified_by'] as String?
      ..sourceDeviceId = json['source_device_id'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
  'last_modified': toUtcIso8601String(instance.lastModified),
  'last_modified_by': instance.lastModifiedBy,
  'source_device_id': instance.sourceDeviceId,
  'version': instance.version,
  'device_id': instance.deviceId,
  'device_name': instance.deviceName,
  'os': instance.os,
  'server': instance.server,
  'is_isolated': instance.isIsolated,
  'last_seen': toUtcIso8601String(instance.lastSeen),
  'current_logged_in_user_id': instance.currentLoggedInUserId,
  'device_type': instance.deviceType,
  'manufacturer': instance.manufacturer,
  'model': instance.model,
  'serial_number': instance.serialNumber,
  'processor': instance.processor,
  'ram_gb': instance.ramGb,
  'storage_gb': instance.storageGb,
  'ip_addresses': instance.ipAddresses,
  'mac_addresses': instance.macAddresses,
};

User _$UserFromJson(Map<String, dynamic> json) =>
    User(
        userId: json['user_id'] as String?,
        username: json['username'] as String?,
        parentAdminId: json['parent_admin_id'] as String?,
        email: json['email'] as String?,
        associatedDeviceIds: (json['associated_device_ids'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        license: json['license'] as String?,
        groups: (json['groups'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
      )
      ..lastModified = fromUtcIso8601String(json['last_modified'] as String?)
      ..lastModifiedBy = json['last_modified_by'] as String?
      ..sourceDeviceId = json['source_device_id'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'last_modified': toUtcIso8601String(instance.lastModified),
  'last_modified_by': instance.lastModifiedBy,
  'source_device_id': instance.sourceDeviceId,
  'version': instance.version,
  'user_id': instance.userId,
  'username': instance.username,
  'parent_admin_id': instance.parentAdminId,
  'email': instance.email,
  'associated_device_ids': instance.associatedDeviceIds,
  'license': instance.license,
  'groups': instance.groups,
};

Policy _$PolicyFromJson(Map<String, dynamic> json) =>
    Policy(
        policyId: json['policy_id'] as String?,
        policyName: json['policy_name'] as String?,
        policyJson: json['policy_json'] as Map<String, dynamic>?,
        createdByAdminId: json['created_by_admin_id'] as String?,
        applicableLayer: (json['applicable_layer'] as num?)?.toInt(),
      )
      ..lastModified = fromUtcIso8601String(json['last_modified'] as String?)
      ..lastModifiedBy = json['last_modified_by'] as String?
      ..sourceDeviceId = json['source_device_id'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$PolicyToJson(Policy instance) => <String, dynamic>{
  'last_modified': toUtcIso8601String(instance.lastModified),
  'last_modified_by': instance.lastModifiedBy,
  'source_device_id': instance.sourceDeviceId,
  'version': instance.version,
  'policy_id': instance.policyId,
  'policy_name': instance.policyName,
  'policy_json': instance.policyJson,
  'created_by_admin_id': instance.createdByAdminId,
  'applicable_layer': instance.applicableLayer,
};

Threat _$ThreatFromJson(Map<String, dynamic> json) =>
    Threat(
        threatId: json['threat_id'] as String?,
        threatName: json['threat_name'] as String?,
        deviceId: json['device_id'] as String?,
        detectionTimestamp: fromUtcIso8601String(
          json['detection_timestamp'] as String?,
        ),
        status: json['status'] as String?,
      )
      ..lastModified = fromUtcIso8601String(json['last_modified'] as String?)
      ..lastModifiedBy = json['last_modified_by'] as String?
      ..sourceDeviceId = json['source_device_id'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$ThreatToJson(Threat instance) => <String, dynamic>{
  'last_modified': toUtcIso8601String(instance.lastModified),
  'last_modified_by': instance.lastModifiedBy,
  'source_device_id': instance.sourceDeviceId,
  'version': instance.version,
  'threat_id': instance.threatId,
  'threat_name': instance.threatName,
  'device_id': instance.deviceId,
  'detection_timestamp': toUtcIso8601String(instance.detectionTimestamp),
  'status': instance.status,
};

UserPhoto _$UserPhotoFromJson(Map<String, dynamic> json) =>
    UserPhoto(
        photoId: json['photo_id'] as String?,
        userId: json['user_id'] as String?,
        deviceId: json['device_id'] as String?,
        threatId: json['threat_id'] as String?,
        photoData: json['photo_data'] as String?,
        timestamp: fromUtcIso8601String(json['timestamp'] as String?),
      )
      ..lastModified = fromUtcIso8601String(json['last_modified'] as String?)
      ..lastModifiedBy = json['last_modified_by'] as String?
      ..sourceDeviceId = json['source_device_id'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$UserPhotoToJson(UserPhoto instance) => <String, dynamic>{
  'last_modified': toUtcIso8601String(instance.lastModified),
  'last_modified_by': instance.lastModifiedBy,
  'source_device_id': instance.sourceDeviceId,
  'version': instance.version,
  'photo_id': instance.photoId,
  'user_id': instance.userId,
  'device_id': instance.deviceId,
  'threat_id': instance.threatId,
  'photo_data': instance.photoData,
  'timestamp': toUtcIso8601String(instance.timestamp),
};

DataIntegrityLog _$DataIntegrityLogFromJson(Map<String, dynamic> json) =>
    DataIntegrityLog(
        logId: json['log_id'] as String?,
        deviceId: json['device_id'] as String?,
        filePath: json['file_path'] as String?,
        dataHash: json['data_hash'] as String?,
        timestamp: fromUtcIso8601String(json['timestamp'] as String?),
        previousHash: json['previous_hash'] as String?,
      )
      ..lastModified = fromUtcIso8601String(json['last_modified'] as String?)
      ..lastModifiedBy = json['last_modified_by'] as String?
      ..sourceDeviceId = json['source_device_id'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$DataIntegrityLogToJson(DataIntegrityLog instance) =>
    <String, dynamic>{
      'last_modified': toUtcIso8601String(instance.lastModified),
      'last_modified_by': instance.lastModifiedBy,
      'source_device_id': instance.sourceDeviceId,
      'version': instance.version,
      'log_id': instance.logId,
      'device_id': instance.deviceId,
      'file_path': instance.filePath,
      'data_hash': instance.dataHash,
      'timestamp': toUtcIso8601String(instance.timestamp),
      'previous_hash': instance.previousHash,
    };

LicenseKey _$LicenseKeyFromJson(Map<String, dynamic> json) => LicenseKey(
  id: json['id'] as String?,
  key: json['key'] as String?,
  isActive: json['is_active'] as bool?,
  assignedAdmin: json['assigned_admin'] as String?,
  dateCreated: fromUtcIso8601String(json['date_created'] as String?),
);

Map<String, dynamic> _$LicenseKeyToJson(LicenseKey instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'is_active': instance.isActive,
      'assigned_admin': instance.assignedAdmin,
      'date_created': toUtcIso8601String(instance.dateCreated),
    };

SyncLog _$SyncLogFromJson(Map<String, dynamic> json) => SyncLog(
  logId: json['log_id'] as String?,
  admin: json['admin'] as String?,
  timestamp: fromUtcIso8601String(json['timestamp'] as String?),
  requestData: json['request_data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SyncLogToJson(SyncLog instance) => <String, dynamic>{
  'log_id': instance.logId,
  'admin': instance.admin,
  'timestamp': toUtcIso8601String(instance.timestamp),
  'request_data': instance.requestData,
};

Group _$GroupFromJson(Map<String, dynamic> json) =>
    Group(
        groupId: json['group_id'] as String?,
        groupName: json['group_name'] as String?,
        description: json['description'] as String?,
        license: json['license'] as String?,
      )
      ..lastModified = fromUtcIso8601String(json['last_modified'] as String?)
      ..lastModifiedBy = json['last_modified_by'] as String?
      ..sourceDeviceId = json['source_device_id'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
  'last_modified': toUtcIso8601String(instance.lastModified),
  'last_modified_by': instance.lastModifiedBy,
  'source_device_id': instance.sourceDeviceId,
  'version': instance.version,
  'group_id': instance.groupId,
  'group_name': instance.groupName,
  'description': instance.description,
  'license': instance.license,
};
