// lib/ui/home_screen.dart

import 'package:flutter/material.dart';
import 'package:resilient_sync_app/database/isar_service.dart';
import 'package:resilient_sync_app/database/models/sync_action.dart';
import 'package:resilient_sync_app/services/crud_service.dart';
import 'package:resilient_sync_app/services/sync_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SyncService _syncService = SyncService();
  int _outboxCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshCount(); // Load the count when the screen first opens
  }

  // A method to get the number of items from the database
  Future<void> _refreshCount() async {
    final isar = await IsarService.instance.getDb();
    // The ".syncActions" and ".findAll()" methods are created by the build_runner.
    // This line will work after the build command succeeds.
    final allActions = await isar.syncActions.where().findAll();
    setState(() {
      _outboxCount = allActions.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Server Dashboard"),
        actions: [
          // Add a refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCount,
            tooltip: 'Refresh Count',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Status: Running",
                style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            // This is the new, simpler way to show the count
            Card(
              child: ListTile(
                title: const Text("Pending Outbox Items"),
                trailing: Text(
                  _outboxCount.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _syncService.processOutbox();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Manual sync triggered!")),
                  );
                  _refreshCount(); // Update the count after syncing
                },
                child: const Text("Force Sync Now"),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateUserDialog(context),
        tooltip: 'Create New User',
        child: const Icon(Icons.add),
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
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                // This is the corrected part
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                await crudService.createUser(
                  username: usernameController.text,
                  email: emailController.text,
                );

                navigator.pop();
                messenger.showSnackBar(const SnackBar(
                  content: Text("User created and queued for sync."),
                ));

                _refreshCount();
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }
}
