import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? userId; // Permanent UUID from cloud

  @Index()
  late String localId;

  @Index(unique: true, caseSensitive: false)
  late String username;

  late String email;
  late List<String> associatedDeviceIds;

  String? parentAdminId;
  String? licenseId;

  User();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'localId': localId,
      'username': username,
      'email': email,
      'associatedDeviceIds': associatedDeviceIds,
      'parentAdminId': parentAdminId,
      'licenseId': licenseId,
    };
  }
}
