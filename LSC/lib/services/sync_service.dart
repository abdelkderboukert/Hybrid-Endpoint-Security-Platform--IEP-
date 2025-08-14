import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:resilient_sync_app/api/api_client_service.dart';
import 'package:resilient_sync_app/config/app_config_service.dart';
import 'package:resilient_sync_app/database/isar_service.dart';
import 'package:resilient_sync_app/database/models/sync_action.dart';
import 'package:isar/isar.dart';

class SyncService {
  final IsarService _isarService = IsarService.instance;
  final AppConfigService _config = AppConfigService();
  final ApiClientService _apiClient = ApiClientService();
  final Dio _dio = Dio(); // Used for parent communication

  /// Processes all pending actions in the outbox.
  /// This is the main "Smart Sync" algorithm.
  Future<void> processOutbox() async {
    final isar = await _isarService.getDb();
    final pendingActions = await isar.syncActions.where().findAll();

    if (pendingActions.isEmpty) return;
    print("Processing ${pendingActions.length} items in outbox...");

    for (final action in pendingActions) {
      bool successful = false;

      // Rule 1: Attempt to Sync with Parent (unless we are Layer 0)
      if (!_config.isLayer0()) {
        successful = await _sendToParent(action);
      }

      // Rule 2: If Parent Fails (or we are Layer 0), Attempt to Sync with Cloud
      if (!successful) {
        successful = await _sendToCloud(action);
      }

      // If sent successfully, remove from our local outbox
      if (successful) {
        await isar.writeTxn(() async {
          await isar.syncActions.delete(action.id);
        });
        print("Successfully synced action for localId: ${action.localId}");
      }
    }
  }

  /// Tries to send a SyncAction to the configured parent server.
  Future<bool> _sendToParent(SyncAction action) async {
    final parentIp = _config.getParentIp();
    if (parentIp == null || parentIp.isEmpty) return false;

    final url =
        'http://$parentIp:8080/sync'; // Standard port for our local server
    try {
      final response = await _dio.post(
        url,
        data: {
          'actionType': action.actionType,
          'payload': action.payload,
          'localId': action.localId,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Failed to sync with parent server at $url. Error: $e");
      return false;
    }
  }

  /// Tries to send a SyncAction directly to the main cloud backend.
  Future<bool> _sendToCloud(SyncAction action) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print("No internet connection to reach the cloud.");
      return false; // No internet, can't reach cloud
    }
    print("Attempting to bypass parent and send to cloud...");
    return await _apiClient.sendToCloud(action);
  }

  // This would be triggered by Layer 0 admin.
  Future<void> syncDown() async {
    if (!_config.isLayer0()) {
      print("Only Layer 0 admin can initiate sync down from cloud.");
      return;
    }

    final updates = await _apiClient.fetchUpdatesFromCloud();
    if (updates != null) {
      final isar = await _isarService.getDb();
      // Here you would parse the 'updates' map and save the data
      // into your local Isar database.
      // This is the reconciliation step where local IDs are updated
      // with permanent server UUIDs.
      // Example:
      // final users = (updates['users'] as List).map((u) => User.fromJson(u)).toList();
      // await isar.writeTxn(() async {
      //   await isar.users.putAll(users);
      // });
      print("Data successfully synced down from the cloud.");

      // After saving, the data is now available to be propagated down
      // to children when they connect.
    }
  }
}
