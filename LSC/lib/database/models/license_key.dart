import 'package:isar/isar.dart';

part 'license_key.g.dart';

@collection
class LicenseKey {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? licenseKeyId; // Permanent UUID from cloud (was 'id')

  @Index()
  late String localId;

  @Index(unique: true)
  late String key;

  late bool isActive;
  late DateTime dateCreated;
  
  // This field replaces the OneToOneField relationship
  String? assignedAdminId;

  LicenseKey();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'licenseKeyId': licenseKeyId,
      'localId': localId,
      'key': key,
      'isActive': isActive,
      'dateCreated': dateCreated.toIso8601String(),
      'assignedAdminId': assignedAdminId,
    };
  }
}