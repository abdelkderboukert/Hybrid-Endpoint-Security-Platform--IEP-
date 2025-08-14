// lib/ui/home_screen.dart

import 'package:async/async.dart'; // <-- MAKE SURE YOU HAVE THIS IMPORT
import 'package:flutter/material.dart';
import 'package:resilient_sync_app/database/isar_service.dart';
import 'package:resilient_sync_app/database/models/sync_action.dart';
import 'package:resilient_sync_app/services/crud_service.dart';
import 'package:resilient_sync_app/services/sync_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final syncService = SyncService();

    return Scaffold(
      appBar: AppBar(title: const Text("Server Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Status: Running",
                style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            // This is the corrected StreamBuilder
            StreamBuilder<List<SyncAction>>(
              // This line requires the 'async' package
              stream: IsarService.instance
                  .getDb()
                  .asStream()
                  .asyncMap((isar) =>
                      isar.syncActions.where().watch(fireImmediately: true))
                  .flatMap((stream) => stream),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return Card(
                  child: ListTile(
                    title: const Text("Pending Outbox Items"),
                    trailing: Text(count.toString(),
                        style: Theme.of(context).textTheme.headlineMedium),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  syncService.processOutbox();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Manual sync triggered!")));
                },
                child: const Text("Force Sync Now"),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateUserDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Create New User',
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final crudService = CrudService();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create New User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username')),
              TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email')),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                crudService.createUser(
                  username: usernameController.text,
                  email: emailController.text,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("User created and queued for sync.")));
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }
}
