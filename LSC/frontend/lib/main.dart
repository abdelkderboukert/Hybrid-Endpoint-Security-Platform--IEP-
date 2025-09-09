// import 'package:fluent_ui/fluent_ui.dart';
// import 'package:window_manager/window_manager.dart';
// import 'package:frontend/screens/splash_screen.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await windowManager.ensureInitialized();
//   final storage = const FlutterSecureStorage();
//   await storage.delete(key: 'access_token');
//   await storage.delete(key: 'refresh_token');
//   runApp(const MyApp());
// }

// class ThemeNotifier extends ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.light;

//   ThemeMode get themeMode => _themeMode;

//   void toggleTheme(bool isDarkMode) {
//     _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
//     notifyListeners();
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FluentApp(
//       title: 'LSC Frontend',
//       debugShowCheckedModeBanner: false,
//       theme: FluentThemeData(brightness: Brightness.dark),
//       home: const SplashScreen(),
//     );
//   }
// }

import 'dart:io';
import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:frontend/screens/splash_screen.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final Map<String, String> env = {};

void main() async {
  // Your existing main function logic
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  final storage = const FlutterSecureStorage();
  await storage.delete(key: 'access_token');
  await storage.delete(key: 'refresh_token');
  await _loadEnvFromFile('C:\\Bluck D-ESC_env\\.env');

  runApp(const MyApp());
}

Future<void> _loadEnvFromFile(String path) async {
  // This code is specific to desktop platforms
  if (!Platform.isWindows) {
    print("This method is for Windows desktop builds only.");
    return;
  }

  try {
    final file = File(path);
    if (await file.exists()) {
      final lines = await file.readAsLines();
      for (var line in lines) {
        if (line.trim().isEmpty || line.trim().startsWith('#')) continue;
        final parts = line.split('=');
        if (parts.length == 2) {
          env[parts[0].trim()] = parts[1].trim();
        }
      }
      print("✅ Successfully loaded config from $path");
    } else {
      print("❌ Error: Config file not found at $path");
    }
  } catch (e) {
    print("❌ Error reading config file: $e");
  }
}

// Your ThemeNotifier class remains unchanged
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

// Converted MyApp to a StatefulWidget to manage the backend process
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Process? _backendProcess;

  @override
  void initState() {
    super.initState();
    // Start the backend when the app launches
    _setupAndRunBackend();
  }

  @override
  void dispose() {
    // IMPORTANT: Shut down the backend when the app closes
    print("Closing backend process...");
    _backendProcess?.kill();
    super.dispose();
  }

  Future<void> _setupAndRunBackend() async {
    // 1. Define paths for extraction
    final appSupportDir = await getApplicationSupportDirectory();
    final backendDir = Directory(p.join(appSupportDir.path, 'backend'));
    final backendExe = File(
      p.join(backendDir.path, 'DSEC_Local_Server.exe'),
    ); // Make sure this name is correct

    // 2. Extract backend from assets if it's not already there
    if (!await backendExe.exists()) {
      print("Backend not found. Extracting from assets...");

      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final assetPaths = manifestMap.keys
          .where((String key) => key.startsWith('assets/backend/'))
          .toList();

      for (final assetPath in assetPaths) {
        final relativePath = assetPath.replaceFirst('assets/backend/', '');
        final file = File(p.join(backendDir.path, relativePath));

        await file.parent.create(recursive: true);

        final assetData = await rootBundle.load(assetPath);
        await file.writeAsBytes(assetData.buffer.asUint8List());
        print("Extracted: ${file.path}");
      }
    } else {
      print("Backend already extracted.");
    }

    // 3. Run the backend executable
    try {
      print("Starting backend at: ${backendExe.path}");
      _backendProcess = await Process.start(
        backendExe.path,
        [],
        workingDirectory: backendDir.path, // Set working directory
      );

      // Optional: Listen to backend output for debugging
      _backendProcess?.stdout
          .transform(utf8.decoder)
          .listen((data) => print("Backend STDOUT: ${data.trim()}"));
      _backendProcess?.stderr
          .transform(utf8.decoder)
          .listen((data) => print("Backend STDERR: ${data.trim()}"));
    } catch (e) {
      print("Error starting backend process: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Your existing UI build method
    return FluentApp(
      title: 'LSC Frontend',
      debugShowCheckedModeBanner: false,
      theme: FluentThemeData(brightness: Brightness.dark),
      home: const SplashScreen(),
    );
  }
}
//////////////////////////////////////////////////////////////////////////////////////////////
// import 'package:flutter/material.dart';
// import 'dart:ui'; // Needed for Offset

// // --- 1. Data Models (No changes needed) ---
// abstract class NetworkDevice {
//   final String id;
//   final String name;
//   NetworkDevice({required this.id, required this.name});
// }

// class Server extends NetworkDevice {
//   final List<NetworkDevice> children;
//   Server({required super.id, required super.name, this.children = const []});
// }

// class Client extends NetworkDevice {
//   final String ipAddress;
//   final String status;
//   Client({
//     required super.id,
//     required super.name,
//     required this.ipAddress,
//     required this.status,
//   });
// }

// // --- Mock Data (No changes needed) ---
// final rootServer = Server(
//   id: 'server-1',
//   name: 'Main Datacenter',
//   children: [
//     Client(
//       id: 'client-1',
//       name: 'Admin PC',
//       ipAddress: '192.168.1.10',
//       status: 'Online',
//     ),
//     Client(
//       id: 'client-2',
//       name: 'Marketing PC',
//       ipAddress: '192.168.1.12',
//       status: 'Offline',
//     ),
//     Server(
//       id: 'server-2',
//       name: 'Development Server',
//       children: [
//         Client(
//           id: 'client-3',
//           name: 'Dev-John-Laptop',
//           ipAddress: '10.0.0.5',
//           status: 'Online',
//         ),
//         Client(
//           id: 'client-4',
//           name: 'Dev-Jane-Laptop',
//           ipAddress: '10.0.0.6',
//           status: 'Online',
//         ),
//         Server(
//           id: 'server-8',
//           name: 'Testing Sub-Server',
//           children: [
//             Client(
//               id: 'client-8',
//               name: 'QA Machine',
//               ipAddress: '10.0.1.20',
//               status: 'Online',
//             ),
//             Server(
//               id: 'server-9',
//               name: 'Testing Sub-Server',
//               children: [
//                 Client(
//                   id: 'client-6',
//                   name: 'QA Machine',
//                   ipAddress: '10.0.1.20',
//                   status: 'Online',
//                 ),
//                 Server(
//                   id: 'server-11',
//                   name: 'Testing Sub-Server',
//                   children: [
//                     Client(
//                       id: 'client-11',
//                       name: 'QA Machine',
//                       ipAddress: '10.0.1.20',
//                       status: 'Online',
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     ),
//     Server(
//       id: 'server-3',
//       name: 'Backup Server',
//       children: [
//         Client(
//           id: 'client-5',
//           name: 'Backup Agent',
//           ipAddress: '172.16.0.100',
//           status: 'Connected',
//         ),
//       ],
//     ),
//   ],
// );

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Server Dashboard',
//       theme: ThemeData(
//         brightness: Brightness.dark,
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//         scaffoldBackgroundColor: const Color(0xFF1a1a2e),
//       ),
//       home: const DashboardScreen(),
//     );
//   }
// }

// class Connection {
//   final Offset start;
//   final Offset end;
//   Connection(this.start, this.end);
// }

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   final Map<String, bool> _expandedState = {'server-1': true};
//   final Map<String, GlobalKey> _nodeKeys = {};
//   List<Connection> _connections = [];
//   final GlobalKey _stackKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     _generateKeys(rootServer);
//     WidgetsBinding.instance.addPostFrameCallback(
//       (_) => _calculateConnections(),
//     );
//   }

//   void _generateKeys(NetworkDevice device) {
//     _nodeKeys[device.id] = GlobalKey();
//     if (device is Server) {
//       for (var child in device.children) {
//         _generateKeys(child);
//       }
//     }
//   }

//   void _toggleExpanded(String serverId) {
//     setState(() {
//       _expandedState[serverId] = !(_expandedState[serverId] ?? false);
//       WidgetsBinding.instance.addPostFrameCallback(
//         (_) => _calculateConnections(),
//       );
//     });
//   }

//   void _calculateConnections() {
//     final newConnections = <Connection>[];
//     final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
//     if (stackBox == null) return;
//     final stackOffset = stackBox.localToGlobal(Offset.zero);

//     void findConnections(Server server) {
//       final parentKey = _nodeKeys[server.id];
//       final parentBox =
//           parentKey?.currentContext?.findRenderObject() as RenderBox?;
//       if (parentBox == null) return;

//       // CHANGED: Connection point is now the middle-right of the parent.
//       final parentPosition =
//           parentBox.localToGlobal(
//             Offset(parentBox.size.width, parentBox.size.height / 2),
//           ) -
//           stackOffset;

//       if (_expandedState[server.id] == true) {
//         for (final child in server.children) {
//           final childKey = _nodeKeys[child.id];
//           final childBox =
//               childKey?.currentContext?.findRenderObject() as RenderBox?;
//           if (childBox != null) {
//             // CHANGED: Connection point is now the middle-left of the child.
//             final childPosition =
//                 childBox.localToGlobal(Offset(0, childBox.size.height / 2)) -
//                 stackOffset;
//             newConnections.add(Connection(parentPosition, childPosition));
//             if (child is Server) {
//               findConnections(child);
//             }
//           }
//         }
//       }
//     }

//     findConnections(rootServer);
//     setState(() {
//       _connections = newConnections;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Server Network Graph'),
//         backgroundColor: const Color(0xFF16213e),
//       ),
//       body: SingleChildScrollView(
//         // CHANGED: Scroll direction is now horizontal.
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.all(24.0),
//         child: Stack(
//           key: _stackKey,
//           children: [
//             CustomPaint(painter: _TreePainter(connections: _connections)),
//             _buildNode(rootServer, 0),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Recursively builds the widget tree of nodes.
//   Widget _buildNode(NetworkDevice device, int depth) {
//     // CHANGED: The main layout is now a Row.
//     if (device is Server) {
//       final isExpanded = _expandedState[device.id] ?? false;
//       return Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           _ServerWidget(
//             key: _nodeKeys[device.id],
//             server: device,
//             isExpanded: isExpanded,
//             onTap: () => _toggleExpanded(device.id),
//           ),
//           if (isExpanded)
//             Padding(
//               // Add some space between parent and children column.
//               padding: const EdgeInsets.only(left: 40.0),
//               // Children are in a vertical column.
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: device.children
//                     .map((child) => _buildNode(child, depth + 1))
//                     .toList(),
//               ),
//             ),
//         ],
//       );
//     } else if (device is Client) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: _ClientWidget(key: _nodeKeys[device.id], client: device),
//       );
//     }
//     return const SizedBox.shrink();
//   }
// }

// class _TreePainter extends CustomPainter {
//   final List<Connection> connections;
//   _TreePainter({required this.connections});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.blueGrey[600]!
//       ..strokeWidth = 2.0
//       ..style = PaintingStyle.stroke;

//     for (final connection in connections) {
//       canvas.drawLine(connection.start, connection.end, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// // --- Node Widgets (No major changes needed) ---
// class _ServerWidget extends StatelessWidget {
//   final Server server;
//   final bool isExpanded;
//   final VoidCallback onTap;
//   const _ServerWidget({
//     super.key,
//     required this.server,
//     required this.isExpanded,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 8.0),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: const Color(0xFF0f3460),
//           border: Border.all(color: Colors.cyan),
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               isExpanded ? Icons.folder_open_outlined : Icons.folder_outlined,
//               color: Colors.cyanAccent,
//             ),
//             const SizedBox(width: 12),
//             Text(
//               server.name,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ClientWidget extends StatelessWidget {
//   final Client client;
//   const _ClientWidget({super.key, required this.client});

//   Color get _statusColor {
//     switch (client.status) {
//       case 'Online':
//       case 'Connected':
//         return Colors.greenAccent;
//       case 'Offline':
//         return Colors.redAccent;
//       default:
//         return Colors.orangeAccent;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Info: ${client.name} | IP: ${client.ipAddress} | Status: ${client.status}',
//             ),
//             backgroundColor: _statusColor.withOpacity(0.8),
//           ),
//         );
//       },
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircleAvatar(
//             radius: 20,
//             backgroundColor: _statusColor.withOpacity(0.3),
//             child: Icon(Icons.computer, color: _statusColor, size: 20),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(client.name),
//               Text(
//                 client.status,
//                 style: TextStyle(color: _statusColor, fontSize: 12),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
////////////////////////////////////////////////////////////////////////////////////////////////////
// import 'package:flutter/material.dart';
// import 'dart:ui'; // Needed for Offset
// import 'package:frontend/services/api_service.dart'; // Your ApiService import
// import 'models/models.dart'; // ✅ Imports from your single, consolidated models file

// // --- DATA MODELS ARE NO LONGER DEFINED IN THIS FILE ---

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Server Dashboard',
//       theme: ThemeData(
//         brightness: Brightness.dark,
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//         scaffoldBackgroundColor: const Color(0xFF1a1a2e),
//       ),
//       home: const DashboardScreen(),
//     );
//   }
// }

// class Connection {
//   final Offset start;
//   final Offset end;
//   Connection(this.start, this.end);
// }

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   // State variables now use the specific hierarchy models
//   ServerNode? rootServer; // ✅ CHANGED
//   bool _isLoading = true;
//   String? _error;
//   final ApiService _apiService = ApiService();

//   final Map<String, bool> _expandedState = {};
//   final Map<String, GlobalKey> _nodeKeys = {};
//   List<Connection> _connections = [];
//   final GlobalKey _stackKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   Future<void> _fetchData() async {
//     try {
//       final List<ServerNode> servers = await _apiService
//           .fetchNetworkHierarchy();

//       // Create a "virtual" root node to hold all servers from the API
//       final virtualRoot = ServerNode(
//         id: 'virtual-root',
//         name: 'Company Network',
//         children: servers,
//       );

//       setState(() {
//         rootServer = virtualRoot;
//         _expandedState[virtualRoot.id] = true;
//         _generateKeys(rootServer!);
//         _isLoading = false;
//         WidgetsBinding.instance.addPostFrameCallback(
//           (_) => _calculateConnections(),
//         );
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   void _generateKeys(NetworkNode device) {
//     // ✅ CHANGED
//     _nodeKeys[device.id] = GlobalKey();
//     if (device is ServerNode) {
//       // ✅ CHANGED
//       for (var child in device.children) {
//         _generateKeys(child);
//       }
//     }
//   }

//   void _toggleExpanded(String serverId) {
//     setState(() {
//       _expandedState[serverId] = !(_expandedState[serverId] ?? false);
//       WidgetsBinding.instance.addPostFrameCallback(
//         (_) => _calculateConnections(),
//       );
//     });
//   }

//   void _calculateConnections() {
//     if (rootServer == null) return;

//     final newConnections = <Connection>[];
//     final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
//     if (stackBox == null) return;
//     final stackOffset = stackBox.localToGlobal(Offset.zero);

//     void findConnections(ServerNode server) {
//       // ✅ CHANGED
//       final parentKey = _nodeKeys[server.id];
//       final parentBox =
//           parentKey?.currentContext?.findRenderObject() as RenderBox?;
//       if (parentBox == null) return;

//       final parentPosition =
//           parentBox.localToGlobal(
//             Offset(parentBox.size.width, parentBox.size.height / 2),
//           ) -
//           stackOffset;

//       if (_expandedState[server.id] == true) {
//         for (final child in server.children) {
//           final childKey = _nodeKeys[child.id];
//           final childBox =
//               childKey?.currentContext?.findRenderObject() as RenderBox?;
//           if (childBox != null) {
//             final childPosition =
//                 childBox.localToGlobal(Offset(0, childBox.size.height / 2)) -
//                 stackOffset;
//             newConnections.add(Connection(parentPosition, childPosition));
//             if (child is ServerNode) {
//               // ✅ CHANGED
//               findConnections(child);
//             }
//           }
//         }
//       }
//     }

//     findConnections(rootServer!);
//     setState(() {
//       _connections = newConnections;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Server Network Graph'),
//         backgroundColor: const Color(0xFF16213e),
//       ),
//       body: _buildBody(),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (_error != null) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Text(
//             'Failed to load data:\n$_error',
//             style: const TextStyle(color: Colors.redAccent),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       );
//     }
//     if (rootServer == null) {
//       return const Center(child: Text('No data available.'));
//     }

//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       padding: const EdgeInsets.all(24.0),
//       child: Stack(
//         key: _stackKey,
//         children: [
//           CustomPaint(painter: _TreePainter(connections: _connections)),
//           _buildNode(rootServer!, 0),
//         ],
//       ),
//     );
//   }

//   /// Recursively builds the widget tree of nodes.
//   Widget _buildNode(NetworkNode device, int depth) {
//     // ✅ CHANGED
//     if (device is ServerNode) {
//       // ✅ CHANGED
//       final isExpanded = _expandedState[device.id] ?? false;
//       return Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           _ServerWidget(
//             key: _nodeKeys[device.id],
//             server: device,
//             isExpanded: isExpanded,
//             onTap: () => _toggleExpanded(device.id),
//           ),
//           if (isExpanded)
//             Padding(
//               padding: const EdgeInsets.only(left: 40.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: device.children
//                     .map((child) => _buildNode(child, depth + 1))
//                     .toList(),
//               ),
//             ),
//         ],
//       );
//     } else if (device is ClientNode) {
//       // ✅ CHANGED
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: _ClientWidget(key: _nodeKeys[device.id], client: device),
//       );
//     }
//     return const SizedBox.shrink();
//   }
// }

// class _TreePainter extends CustomPainter {
//   final List<Connection> connections;
//   _TreePainter({required this.connections});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.blueGrey[600]!
//       ..strokeWidth = 2.0
//       ..style = PaintingStyle.stroke;

//     for (final connection in connections) {
//       canvas.drawLine(connection.start, connection.end, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// class _ServerWidget extends StatelessWidget {
//   final ServerNode server; // ✅ CHANGED
//   final bool isExpanded;
//   final VoidCallback onTap;
//   const _ServerWidget({
//     super.key,
//     required this.server,
//     required this.isExpanded,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 8.0),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: const Color(0xFF0f3460),
//           border: Border.all(color: Colors.cyan),
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               isExpanded ? Icons.folder_open_outlined : Icons.folder_outlined,
//               color: Colors.cyanAccent,
//             ),
//             const SizedBox(width: 12),
//             Text(
//               server.name,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ClientWidget extends StatelessWidget {
//   final ClientNode client; // ✅ CHANGED
//   const _ClientWidget({super.key, required this.client});

//   Color get _statusColor {
//     switch (client.status) {
//       case 'Online':
//       case 'Connected':
//         return Colors.greenAccent;
//       case 'Offline':
//         return Colors.redAccent;
//       default:
//         return Colors.orangeAccent;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Info: ${client.name} | IP: ${client.ipAddress} | Status: ${client.status}',
//             ),
//             backgroundColor: _statusColor.withOpacity(0.8),
//           ),
//         );
//       },
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircleAvatar(
//             radius: 20,
//             backgroundColor: _statusColor.withOpacity(0.3),
//             child: Icon(Icons.computer, color: _statusColor, size: 20),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(client.name),
//               Text(
//                 client.status,
//                 style: TextStyle(color: _statusColor, fontSize: 12),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
