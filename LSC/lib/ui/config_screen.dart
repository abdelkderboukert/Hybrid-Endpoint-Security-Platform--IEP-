// (This is a conceptual UI file. You can build it out with more detail)
import 'package:flutter/material.dart';
import 'package:resilient_sync_app/config/app_config_service.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _layerController = TextEditingController();
  final _parentIpController = TextEditingController();
  final _licenseKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Initial Server Setup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _layerController,
                decoration: const InputDecoration(
                    labelText: 'Server Layer (e.g., 0, 1, 2)')),
            TextField(
                controller: _parentIpController,
                decoration: const InputDecoration(
                    labelText: "Parent Server IP (leave empty for Layer 0)")),
            TextField(
                controller: _licenseKeyController,
                decoration: const InputDecoration(labelText: 'License Key')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await AppConfigService().saveConfiguration(
                  layer: int.parse(_layerController.text),
                  parentIp: _parentIpController.text,
                  licenseKey: _licenseKeyController.text,
                );
                if (!mounted) return;
                // Navigate to home screen or restart app
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text("Configuration Saved! Please restart the app.")));
              },
              child: const Text("Save Configuration"),
            )
          ],
        ),
      ),
    );
  }
}
