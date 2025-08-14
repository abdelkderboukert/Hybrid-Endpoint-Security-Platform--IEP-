import 'dart:convert';
import 'dart:io';

import 'package:resilient_sync_app/database/isar_service.dart';
import 'package:resilient_sync_app/database/models/sync_action.dart';
// Make sure you have created these model files
import 'package:resilient_sync_app/database/models/user.dart';
import 'package:resilient_sync_app/database/models/policy.dart';
import 'package:resilient_sync_app/services/sync_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

class LocalServerService {
  final IsarService _isarService = IsarService.instance;
  final SyncService _syncService = SyncService();

  Future<void> start() async {
    final router = Router();

    // Endpoint for child servers to send their data
    router.post('/sync', _syncHandler);

    // Endpoint for child servers to request updates ("Sync Down")
    router.get('/updates', _updatesHandler);

    // This line is corrected to fix the "tear-off" warning
    final handler =
        const Pipeline().addMiddleware(logRequests()).addHandler(router.call);

    try {
      final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
      print('✅ Local server listening on port ${server.port}');
    } catch (e) {
      print("❌ Error starting local server: $e");
    }
  }

  /// Handles incoming sync requests from child servers.
  Future<Response> _syncHandler(Request request) async {
    try {
      final bodyString = await request.readAsString();
      final bodyJson = jsonDecode(bodyString) as Map<String, dynamic>;

      final action = SyncAction()
        ..localId = bodyJson['localId'] as String
        ..actionType = bodyJson['actionType'] as String
        ..payload = bodyJson['payload'] as String
        ..createdAt = DateTime.now();

      final isar = await _isarService.getDb();
      await isar.writeTxn(() async {
        await isar.syncActions.put(action);
      });

      print("📦 Received sync action from child. Added to our outbox.");

      // Asynchronously trigger this server's own sync process
      _syncService.processOutbox();

      return Response.ok('{"status": "received"}',
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(
          body: '{"error": "Failed to process request: $e"}');
    }
  }

  /// Handles requests from children asking for new data.
  Future<Response> _updatesHandler(Request request) async {
    final isar = await _isarService.getDb();

    // The errors about ".users" and ".policys" will be fixed
    // after you run the build_runner command in the next step.
    final allUsers = await isar.users.where().findAll();
    final allPolicies = await isar.policys.where().findAll();

    final data = {
      'users': allUsers.map((u) => u.toJson()).toList(),
      'policies': allPolicies.map((p) => p.toJson()).toList(),
    };

    return Response.ok(jsonEncode(data),
        headers: {'Content-Type': 'application/json'});
  }
}
