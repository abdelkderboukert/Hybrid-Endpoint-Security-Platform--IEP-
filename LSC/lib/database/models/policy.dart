import 'package:isar/isar.dart';

part 'policy.g.dart';

@collection
class Policy {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? policyId; // Permanent UUID from cloud

  @Index()
  late String localId;
  
  late String policyName;
  late String policyJson; // JSON stored as a string
  late int applicableLayer;

  String? createdByAdminId;

  Policy();
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'policyId': policyId,
      'localId': localId,
      'policyName': policyName,
      'policyJson': policyJson,
      'applicableLayer': applicableLayer,
      'createdByAdminId': createdByAdminId,
    };
  }
}