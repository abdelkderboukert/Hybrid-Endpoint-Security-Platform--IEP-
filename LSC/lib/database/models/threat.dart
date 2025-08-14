import 'package:isar/isar.dart';

part 'threat.g.dart';

@collection
class Threat {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? threatId; // Permanent UUID from cloud

  @Index()
  late String localId;

  late String threatName;
  late DateTime detectionTimestamp;
  late String status; // 'Detected', 'Quarantined', 'Remediated'
  
  String? deviceId;

  Threat();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'threatId': threatId,
      'localId': localId,
      'threatName': threatName,
      'detectionTimestamp': detectionTimestamp.toIso8601String(),
      'status': status,
      'deviceId': deviceId,
    };
  }
}