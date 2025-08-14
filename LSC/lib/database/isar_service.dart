import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Import all of your data models here
import 'package:resilient_sync_app/database/models/admin.dart';
import 'package:resilient_sync_app/database/models/device.dart';
import 'package:resilient_sync_app/database/models/license_key.dart';
import 'package:resilient_sync_app/database/models/policy.dart';
import 'package:resilient_sync_app/database/models/server.dart';
import 'package:resilient_sync_app/database/models/sync_action.dart';
import 'package:resilient_sync_app/database/models/threat.dart';
import 'package:resilient_sync_app/database/models/user.dart';
import 'package:resilient_sync_app/database/models/user_photo.dart';

class IsarService {
  late Future<Isar> db;

  // This is the proper singleton pattern
  static final IsarService _instance = IsarService._internal();

  factory IsarService() {
    return _instance;
  }

  // The named, private constructor
  IsarService._internal() {
    db = openDB();
  }

  static IsarService get instance => _instance;

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          AdminSchema,
          DeviceSchema,
          LicenseKeySchema,
          PolicySchema,
          ServerSchema,
          SyncActionSchema,
          ThreatSchema,
          UserSchema,
          UserPhotoSchema,
        ],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  Future<Isar> getDb() => db;
}
