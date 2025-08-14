// lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:resilient_sync_app/config/app_config_service.dart';
import 'package:resilient_sync_app/database/isar_service.dart';
import 'package:resilient_sync_app/local_server/local_server_service.dart';
import 'package:resilient_sync_app/services/sync_service.dart';
import 'package:resilient_sync_app/ui/config_screen.dart';
import 'package:resilient_sync_app/ui/home_screen.dart';
import 'package:resilient_sync_app/ui/login_screen.dart'; // Make sure this import exists

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize services that don't depend on configuration
  await IsarService.instance.openDB();
  await AppConfigService().init();

  // 2. Check if the app is configured
  final bool isConfigured = AppConfigService().isConfigured();

  if (isConfigured) {
    // 3. If configured, start all services
    final localServer = LocalServerService();
    await localServer.start();

    // 4. Start a periodic timer to process the outbox
    final syncService = SyncService();
    Timer.periodic(const Duration(seconds: 30), (timer) {
      print("Periodic sync triggered...");
      syncService.processOutbox();
    });
  }

  runApp(MyApp(isConfigured: isConfigured));
}

// THIS IS THE CLASS YOU NEED TO REPLACE
class MyApp extends StatelessWidget {
  final bool isConfigured;
  const MyApp({super.key, required this.isConfigured});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resilient Sync',
      theme: ThemeData.dark(useMaterial3: true),
      // If not configured, show the setup screen. Otherwise, show the login screen.
      initialRoute: isConfigured ? '/login' : '/config',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/config': (context) => const ConfigScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
