import 'package:isar/isar.dart';

part 'admin.g.dart';

@collection
class Admin {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? adminId; // Permanent UUID from cloud

  @Index()
  late String localId;

  @Index(unique: true, caseSensitive: false)
  late String username;

  late String email;

  // IMPORTANT: Add this field
  // This will store the hashed password synced from the cloud or created locally.
  late String passwordHash;

  String? parentAdminId;
  late int layer;
  String? licenseId;
  String? serverId;

  Admin();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': adminId,
      'localId': localId,
      'username': username,
      'email': email,
      'parentAdminId': parentAdminId,
      'licenseId': licenseId,
      'serverId': serverId,
      'layer': layer,
    };
  }
}
