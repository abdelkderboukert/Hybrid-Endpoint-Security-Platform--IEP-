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
