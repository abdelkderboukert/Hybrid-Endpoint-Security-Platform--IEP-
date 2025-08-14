import 'package:isar/isar.dart';

part 'sync_action.g.dart';

@collection
class SyncAction {
  Id id = Isar.autoIncrement;

  // A temporary ID generated on the device, used to track the object
  // until it gets a permanent UUID from the cloud.
  @Index(unique: true, replace: true)
  late String localId; 

  // e.g., 'CREATE_USER', 'UPDATE_POLICY', 'UPLOAD_PHOTO'
  late String actionType; 
  
  // The actual data for the action, stored as a JSON string.
  late String payload;

  late DateTime createdAt;

  SyncAction();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'localId': localId,
      'actionType': actionType,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}