// lib/models/models.dart

// import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

// Helper function for DateTime to ISO 8601 UTC string conversion
String? toUtcIso8601String(DateTime? date) {
  if (date == null) {
    return null;
  }
  return date.toUtc().toIso8601String();
}

// Helper function for ISO 8601 UTC string to DateTime conversion
DateTime? fromUtcIso8601String(String? date) {
  if (date == null) {
    return null;
  }
  return DateTime.parse(date).toUtc();
}

// --------------------------------------------------------------------------
// Abstract Base Classes for Synchronization
// --------------------------------------------------------------------------

@JsonSerializable(explicitToJson: true)
class SyncableModel {
  @JsonKey(fromJson: fromUtcIso8601String, toJson: toUtcIso8601String)
  DateTime? lastModified;
  String? lastModifiedBy;
  String? sourceDeviceId;
  int? version;

  SyncableModel({
    this.lastModified,
    this.lastModifiedBy,
    this.sourceDeviceId,
    this.version,
  });

  factory SyncableModel.fromJson(Map<String, dynamic> json) =>
      _$SyncableModelFromJson(json);

  Map<String, dynamic> toJson() => _$SyncableModelToJson(this);
}

// --------------------------------------------------------------------------
// 1. Admin Model
// --------------------------------------------------------------------------

@JsonSerializable(explicitToJson: true)
class Admin extends SyncableModel {
  @JsonKey(name: 'admin_id')
  String? adminId;
  String? username;
  String? email;
  @JsonKey(name: 'parent_admin_id')
  String? parentAdminId;
  int? layer;
  String? license; // Represented as a String UUID
  String? server; // Represented as a String UUID
  @JsonKey(name: 'is_active')
  bool? isActive;
  @JsonKey(name: 'is_staff')
  bool? isStaff;
  @JsonKey(name: 'is_superuser')
  bool? isSuperuser;
  @JsonKey(name: 'last_login', fromJson: fromUtcIso8601String, toJson: toUtcIso8601String)
  DateTime? lastLogin;
  @JsonKey(name: 'date_joined', fromJson: fromUtcIso8601String, toJson: toUtcIso8601String)
  DateTime? dateJoined;

  Admin({
    this.adminId,
    this.username,
    this.email,
    this.parentAdminId,
    this.layer,
    this.license,
    this.server,
    this.isActive,
    this.isStaff,
    this.isSuperuser,
    this.lastLogin,
    this.dateJoined,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => _$AdminFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AdminToJson(this);
}

// --------------------------------------------------------------------------
// 2. Server Model
// --------------------------------------------------------------------------

@JsonSerializable(explicitToJson: true)
class Server extends SyncableModel {
  @JsonKey(name: 'server_id')
  String? serverId;
  @JsonKey(name: 'server_type')
  String? serverType;
  @JsonKey(name: 'parent_server')
  String? parentServer; // Represented as a String UUID
  @JsonKey(name: 'is_connected')
  bool? isConnected;
  @JsonKey(name: 'last_heartbeat', fromJson: fromUtcIso8601String, toJson: toUtcIso8601String)
  DateTime? lastHeartbeat;
  @JsonKey(name: 'licence_key')
  String? licenceKey;

  Server({
    this.serverId,
    this.serverType,
    this.parentServer,
    this.isConnected,
    this.lastHeartbeat,
    this.licenceKey,
  });

  factory Server.fromJson(Map<String, dynamic> json) => _$ServerFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ServerToJson(this);
}

// --------------------------------------------------------------------------
// 3. Device Model
// --------------------------------------------------------------------------

@JsonSerializable(explicitToJson: true)
class Device extends SyncableModel {
  @JsonKey(name: 'device_id')
  String? deviceId;
  @JsonKey(name: 'device_name')
  String? deviceName;
  String? os;
  String? server; // Represented as a String UUID
  @JsonKey(name: 'is_isolated')
  bool? isIsolated;
  @JsonKey(name: 'last_seen', fromJson: fromUtcIso8601String, toJson: toUtcIso8601String)
  DateTime? lastSeen;
  @JsonKey(name: 'current_logged_in_user_id')
  String? currentLoggedInUserId;

  Device({
    this.deviceId,
    this.deviceName,
    this.os,
    this.server,
    this.isIsolated,
    this.lastSeen,
    this.currentLoggedInUserId,
  });

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}

// --------------------------------------------------------------------------
// 4. User Model
// --------------------------------------------------------------------------

@JsonSerializable(explicitToJson: true)
class User extends SyncableModel {
  @JsonKey(name: 'user_id')
  String? userId;
  String? username;
  @JsonKey(name: 'parent_admin_id')
  String? parentAdminId;
  String? email;
  @JsonKey(name: 'associated_device_ids')
  List<String>? associatedDeviceIds;
  String? license; // Represented as a String UUID

  User({
    this.userId,
    this.username,
    this.parentAdminId,
    this.email,
    this.associatedDeviceIds,
    this.license,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

// --------------------------------------------------------------------------
// 5. Policy Model
// --------------------------------------------------------------------------

@JsonSerializable(explicitToJson: true)
class Policy extends SyncableModel {
  @JsonKey(name: 'policy_id')
  String? policyId;
  @JsonKey(name: 'policy_name')
  String? policyName;
  @JsonKey(name: 'policy_json')
  Map<String, dynamic>? policyJson;
  @JsonKey(name: 'created_by_admin_id')
  String? createdByAdminId;
  @JsonKey(name: 'applicable_layer')
  int? applicableLayer;

  Policy({
    this.policyId,
    this.policyName,
    this.policyJson,
    this.createdByAdminId,
    this.applicableLayer,
  });

  factory Policy.fromJson(Map<String, dynamic> json) => _$PolicyFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PolicyToJson(this);
}

// --------------------------------------------------------------------------
// 6. Threat Model
// --------------------------------------------------------------------------

@JsonSerializable(explicitToJson: true)
class Threat extends SyncableModel {
  @JsonKey(name: 'threat_id')
  String? threatId;
  @JsonKey(name: 'threat_name')
  String? threatName;
  @JsonKey(name: 'device_id')
  String? deviceId;
  @JsonKey(name: 'detection_timestamp', fromJson: fromUtcIso8601String, toJson: toUtcIso8601String)
  DateTime? detectionTimestamp;
  String? status;

  Threat({
    this.threatId,
    this.threatName,
    this.deviceId,
    this.detectionTimestamp,
    this.status,
  });

  factory Threat.fromJson(Map<String, dynamic> json) => _$ThreatFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ThreatToJson(this);
}

// --------------------------------------------------------------------------
// 7. UserPhoto Model
// --------------------------------------------------------------------------

@JsonSerializable(explicitToJson: true)
class UserPhoto extends SyncableModel {
  @JsonKey(name: 'photo_id')
  String? photoId;
  @JsonKey(name: 'user_id')
  String? userId;
  @JsonKey(name: 'device_id')
  String? deviceId;
  @JsonKey(name: 'threat_id')
  String? threatId;
  @JsonKey(name: 'photo_data')
  String? photoData; // Stored as a Base64 string
  @JsonKey(fromJson: fromUtcIso8601String, toJson: toUtcIso8601String)
  DateTime? timestamp;

  UserPhoto({
    this.photoId,
    this.userId,
    this.deviceId,
    this.threatId,
    this.photoData,
    this.timestamp,
  });

  factory UserPhoto.fromJson(Map<String, dynamic> json) =>
      _$UserPhotoFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$UserPhotoToJson(this);
}

// --------------------------------------------------------------------------
// 8. DataIntegrityLog Model
// --------------------------------------------------------------------------

@JsonSerializable(explicitToJson: true)
class DataIntegrityLog extends SyncableModel {
  @JsonKey(name: 'log_id')
  String? logId;
  @JsonKey(name: 'device_id')
  String? deviceId;
  @JsonKey(name: 'file_path')
  String? filePath;
  @JsonKey(name: 'data_hash')
  String? dataHash;
  @JsonKey(fromJson: fromUtcIso8601String, toJson: toUtcIso8601String)
  DateTime? timestamp;
  @JsonKey(name: 'previous_hash')
  String? previousHash;

  DataIntegrityLog({
    this.logId,
    this.deviceId,
    this.filePath,
    this.dataHash,
    this.timestamp,
    this.previousHash,
  });

  factory DataIntegrityLog.fromJson(Map<String, dynamic> json) =>
      _$DataIntegrityLogFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DataIntegrityLogToJson(this);
}

// --------------------------------------------------------------------------
// 9. LicenseKey Model
// --------------------------------------------------------------------------

@JsonSerializable(explicitToJson: true)
class LicenseKey {
  String? id;
  String? key;
  @JsonKey(name: 'is_active')
  bool? isActive;
  @JsonKey(name: 'assigned_admin')
  String? assignedAdmin;
  @JsonKey(name: 'date_created', fromJson: fromUtcIso8601String, toJson: toUtcIso8601String)
  DateTime? dateCreated;

  LicenseKey({
    this.id,
    this.key,
    this.isActive,
    this.assignedAdmin,
    this.dateCreated,
  });

  factory LicenseKey.fromJson(Map<String, dynamic> json) =>
      _$LicenseKeyFromJson(json);
  Map<String, dynamic> toJson() => _$LicenseKeyToJson(this);
}

// --------------------------------------------------------------------------
// 10. SyncLog Model
// --------------------------------------------------------------------------

@JsonSerializable(explicitToJson: true)
class SyncLog {
  @JsonKey(name: 'log_id')
  String? logId;
  String? admin;
  @JsonKey(fromJson: fromUtcIso8601String, toJson: toUtcIso8601String)
  DateTime? timestamp;
  @JsonKey(name: 'request_data')
  Map<String, dynamic>? requestData;

  SyncLog({
    this.logId,
    this.admin,
    this.timestamp,
    this.requestData,
  });

  factory SyncLog.fromJson(Map<String, dynamic> json) =>
      _$SyncLogFromJson(json);
  Map<String, dynamic> toJson() => _$SyncLogToJson(this);
}