import 'package:isar/isar.dart';

part 'server.g.dart';

@collection
class Server {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? serverId; // Permanent UUID from cloud

  @Index()
  late String localId;

  late String serverType; // 'Cloud', 'Local', 'Sub-Local'
  String? parentServerId;
  late bool isConnected;
  DateTime? lastHeartbeat;

  @Index(unique: true)
  String? licenceKey;

  Server();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serverId': serverId,
      'localId': localId,
      'serverType': serverType,
      'parentServerId': parentServerId,
      'isConnected': isConnected,
      'lastHeartbeat': lastHeartbeat?.toIso8601String(),
      'licenceKey': licenceKey,
    };
  }
}