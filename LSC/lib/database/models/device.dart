import 'package:isar/isar.dart';

part 'device.g.dart';

@collection
class Device {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? deviceId; // Permanent UUID from cloud

  @Index()
  late String localId;

  late String deviceName;
  late String os;
  late bool isIsolated;
  late DateTime lastSeen;

  String? serverId;
  String? currentLoggedInUserId;

  Device();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'localId': localId,
      'deviceName': deviceName,
      'os': os,
      'isIsolated': isIsolated,
      'lastSeen': lastSeen,
      'serverId': serverId,
      'currentLoggedInUserId': currentLoggedInUserId,
    };
  }
}
