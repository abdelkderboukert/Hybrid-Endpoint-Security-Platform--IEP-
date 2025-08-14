import 'dart:convert';
import 'package:resilient_sync_app/database/isar_service.dart';
import 'package:resilient_sync_app/database/models/sync_action.dart';
import 'package:resilient_sync_app/database/models/user.dart'; // Import models you want to create
import 'package:resilient_sync_app/services/sync_service.dart';
import 'package:uuid/uuid.dart';
import 'package:isar/isar.dart';

class CrudService {
  final IsarService _isarService = IsarService.instance;
  final Uuid _uuid = const Uuid();

  /// Creates a new user locally and logs the action for syncing.
  Future<void> createUser({
    required String username,
    required String email,
    String? parentAdminId,
  }) async {
    final isar = await _isarService.getDb();

    // 1. Create the User object with a temporary local ID
    final newUser = User()
      ..localId = _uuid.v4() // Generate a unique local ID
      ..username = username
      ..email = email
      ..parentAdminId = parentAdminId;

    // 2. Create the SyncAction for the outbox
    final syncAction = SyncAction()
      ..localId = newUser.localId // Link action to the object
      ..actionType = 'CREATE_USER'
      ..payload = jsonEncode({
        // The data needed to create the user on other servers
        'localId': newUser.localId,
        'username': newUser.username,
        'email': newUser.email,
        'parentAdminId': newUser.parentAdminId,
      })
      ..createdAt = DateTime.now();

    // 3. Save both to the database in a single transaction
    await isar.writeTxn(() async {
      await isar.users.put(newUser);
      await isar.syncActions.put(syncAction);
    });

    print("Created user '${username}' locally and queued for sync.");

    // 4. (Optional) Immediately try to sync the outbox
    await SyncService().processOutbox();
  }

  /// Logs a delete action for syncing.
  Future<void> deleteUser({required String userLocalId}) async {
    final isar = await _isarService.getDb();

    // Find the user to ensure it exists before deleting
    final user =
        await isar.users.where().localIdEqualTo(userLocalId).findFirst();
    if (user == null) {
      print("Cannot delete: User with localId $userLocalId not found.");
      return;
    }

    final syncAction = SyncAction()
      ..localId = userLocalId
      ..actionType = 'DELETE_USER'
      ..payload =
          jsonEncode({'localId': userLocalId}) // Payload just needs the ID
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.users.delete(user.id); // Delete from local DB
      await isar.syncActions.put(syncAction); // Log the action
    });

    print("Deleted user with localId '$userLocalId' and queued for sync.");
    await SyncService().processOutbox();
  }

  // You would add more methods here: createAdmin, deleteDevice, etc.
}
