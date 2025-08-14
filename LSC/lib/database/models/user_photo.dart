import 'package:isar/isar.dart';

part 'user_photo.g.dart';

@collection
class UserPhoto {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? photoId; // Permanent UUID from cloud

  @Index()
  late String localId;

  late List<int> photoData; // Binary data
  late DateTime timestamp;

  String? userId;
  String? deviceId;
  String? threatId;
  
  UserPhoto();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photoId': photoId,
      'localId': localId,
      'photoData': photoData,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'deviceId': deviceId,
      'threatId': threatId,
    };
  }
}