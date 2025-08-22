// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncableModel _$SyncableModelFromJson(Map<String, dynamic> json) =>
    SyncableModel(
      lastModified: fromUtcIso8601String(json['lastModified'] as String?),
      lastModifiedBy: json['lastModifiedBy'] as String?,
      sourceDeviceId: json['sourceDeviceId'] as String?,
      version: (json['version'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SyncableModelToJson(SyncableModel instance) =>
    <String, dynamic>{
      'lastModified': toUtcIso8601String(instance.lastModified),
      'lastModifiedBy': instance.lastModifiedBy,
      'sourceDeviceId': instance.sourceDeviceId,
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
      ..lastModified = fromUtcIso8601String(json['lastModified'] as String?)
      ..lastModifiedBy = json['lastModifiedBy'] as String?
      ..sourceDeviceId = json['sourceDeviceId'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$AdminToJson(Admin instance) => <String, dynamic>{
  'lastModified': toUtcIso8601String(instance.lastModified),
  'lastModifiedBy': instance.lastModifiedBy,
  'sourceDeviceId': instance.sourceDeviceId,
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
      )
      ..lastModified = fromUtcIso8601String(json['lastModified'] as String?)
      ..lastModifiedBy = json['lastModifiedBy'] as String?
      ..sourceDeviceId = json['sourceDeviceId'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$ServerToJson(Server instance) => <String, dynamic>{
  'lastModified': toUtcIso8601String(instance.lastModified),
  'lastModifiedBy': instance.lastModifiedBy,
  'sourceDeviceId': instance.sourceDeviceId,
  'version': instance.version,
  'server_id': instance.serverId,
  'server_type': instance.serverType,
  'parent_server': instance.parentServer,
  'is_connected': instance.isConnected,
  'last_heartbeat': toUtcIso8601String(instance.lastHeartbeat),
  'licence_key': instance.licenceKey,
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
      )
      ..lastModified = fromUtcIso8601String(json['lastModified'] as String?)
      ..lastModifiedBy = json['lastModifiedBy'] as String?
      ..sourceDeviceId = json['sourceDeviceId'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
  'lastModified': toUtcIso8601String(instance.lastModified),
  'lastModifiedBy': instance.lastModifiedBy,
  'sourceDeviceId': instance.sourceDeviceId,
  'version': instance.version,
  'device_id': instance.deviceId,
  'device_name': instance.deviceName,
  'os': instance.os,
  'server': instance.server,
  'is_isolated': instance.isIsolated,
  'last_seen': toUtcIso8601String(instance.lastSeen),
  'current_logged_in_user_id': instance.currentLoggedInUserId,
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
      )
      ..lastModified = fromUtcIso8601String(json['lastModified'] as String?)
      ..lastModifiedBy = json['lastModifiedBy'] as String?
      ..sourceDeviceId = json['sourceDeviceId'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'lastModified': toUtcIso8601String(instance.lastModified),
  'lastModifiedBy': instance.lastModifiedBy,
  'sourceDeviceId': instance.sourceDeviceId,
  'version': instance.version,
  'user_id': instance.userId,
  'username': instance.username,
  'parent_admin_id': instance.parentAdminId,
  'email': instance.email,
  'associated_device_ids': instance.associatedDeviceIds,
  'license': instance.license,
};

Policy _$PolicyFromJson(Map<String, dynamic> json) =>
    Policy(
        policyId: json['policy_id'] as String?,
        policyName: json['policy_name'] as String?,
        policyJson: json['policy_json'] as Map<String, dynamic>?,
        createdByAdminId: json['created_by_admin_id'] as String?,
        applicableLayer: (json['applicable_layer'] as num?)?.toInt(),
      )
      ..lastModified = fromUtcIso8601String(json['lastModified'] as String?)
      ..lastModifiedBy = json['lastModifiedBy'] as String?
      ..sourceDeviceId = json['sourceDeviceId'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$PolicyToJson(Policy instance) => <String, dynamic>{
  'lastModified': toUtcIso8601String(instance.lastModified),
  'lastModifiedBy': instance.lastModifiedBy,
  'sourceDeviceId': instance.sourceDeviceId,
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
      ..lastModified = fromUtcIso8601String(json['lastModified'] as String?)
      ..lastModifiedBy = json['lastModifiedBy'] as String?
      ..sourceDeviceId = json['sourceDeviceId'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$ThreatToJson(Threat instance) => <String, dynamic>{
  'lastModified': toUtcIso8601String(instance.lastModified),
  'lastModifiedBy': instance.lastModifiedBy,
  'sourceDeviceId': instance.sourceDeviceId,
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
      ..lastModified = fromUtcIso8601String(json['lastModified'] as String?)
      ..lastModifiedBy = json['lastModifiedBy'] as String?
      ..sourceDeviceId = json['sourceDeviceId'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$UserPhotoToJson(UserPhoto instance) => <String, dynamic>{
  'lastModified': toUtcIso8601String(instance.lastModified),
  'lastModifiedBy': instance.lastModifiedBy,
  'sourceDeviceId': instance.sourceDeviceId,
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
      ..lastModified = fromUtcIso8601String(json['lastModified'] as String?)
      ..lastModifiedBy = json['lastModifiedBy'] as String?
      ..sourceDeviceId = json['sourceDeviceId'] as String?
      ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$DataIntegrityLogToJson(DataIntegrityLog instance) =>
    <String, dynamic>{
      'lastModified': toUtcIso8601String(instance.lastModified),
      'lastModifiedBy': instance.lastModifiedBy,
      'sourceDeviceId': instance.sourceDeviceId,
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
