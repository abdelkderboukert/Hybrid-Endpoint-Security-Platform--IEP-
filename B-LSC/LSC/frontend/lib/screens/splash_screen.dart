// import 'package:flutter/material.dart';
// import 'package:frontend/screens/dashboard/dashboard_screen.dart';
// import 'package:frontend/services/auth_service.dart';
// import 'package:frontend/screens/auth/login_screen.dart';
// import './auth_wrapper.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkAuthStatus();
//   }

//   Future<void> _checkAuthStatus() async {
//     final accessToken = await AuthService().getAccessToken();
//     if (accessToken != null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const MyHomePage()),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }

import 'package:flutter/material.dart';
import 'package:frontend/screens/dashboard/dashboard_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'dart:io'; // Required for Process management
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Process? _externalProcess;

  @override
  void initState() {
    super.initState();
    _startExternalProcess(); // Start the executable
    _checkAuthStatus(); // Check authentication and navigate
  }

  // Method to start the external executable

  Future<void> _startExternalProcess() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${appDocDir.path}/bin');

      // Create the destination directory if it doesn't exist
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // List of files to copy from the asset bundle
      // You must list every file and folder you need
      final List<String> assetsToCopy = [
        'assets/bin/DSEC_Local_Server.exe',
        'assets/bin/data/config.json', // Example file inside the 'data' folder
        'assets/bin/data/logs/startup.log', // Another example file
      ];

      // Copy each asset one by one
      for (final assetPath in assetsToCopy) {
        final assetFileName = assetPath.split('/').last;
        final targetFilePath = '${targetDir.path}/$assetFileName';

        final byteData = await rootBundle.load(assetPath);
        final file = File(targetFilePath);

        await file.writeAsBytes(byteData.buffer.asUint8List());
        print('Copied: $assetPath to $targetFilePath');
      }

      // Set executable permissions for the .exe file
      final exePath = '${targetDir.path}/DSEC_Local_Server.exe';
      if (Platform.isLinux || Platform.isMacOS) {
        await Process.run('chmod', ['+x', exePath]);
      }

      // Start the executable from its new location
      _externalProcess = await Process.start(exePath, []);
      print('External process started with PID: ${_externalProcess?.pid}');
    } catch (e) {
      print('Failed to start external process: $e');
    }
  }

  // Method to check auth status and navigate
  Future<void> _checkAuthStatus() async {
    final accessToken = await AuthService().getAccessToken();

    // Add a small delay to allow the splash screen to be seen
    await Future.delayed(const Duration(seconds: 2));

    if (accessToken != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  // Method to stop the external executable
  void _stopExternalProcess() {
    if (_externalProcess != null) {
      _externalProcess!.kill();
      _externalProcess = null;
      print('External process stopped.');
    }
  }

  @override
  void dispose() {
    _stopExternalProcess(); // Stop the executable when the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
