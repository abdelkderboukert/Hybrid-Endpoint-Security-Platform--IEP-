import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart'; // Adjust the import as per your project structure
import 'package:frontend/models/models.dart'; // Make sure your Admin/User model is here
import 'package:frontend/main.dart';

class BuildPage extends StatefulWidget {
  const BuildPage() : super();

  @override
  _BuildPageState createState() => _BuildPageState();
}

class _BuildPageState extends State<BuildPage> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true; // Start as true to show loader while fetching admins
  List<Admin> _admins = []; // Use a consistent model, e.g., Admin
  String? _selectedAdminId;
  String? _serverApiKey;

  // A special, constant value to identify the "Create New" action
  static const String CREATE_NEW_ADMIN_VALUE = 'CREATE_NEW';

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
    _loadApiKey();
  }

  void _loadApiKey() {
    // Access the 'serverApiKey' from the global `env` map
    final key = env['LSC_API_KEY'];

    setState(() {
      _serverApiKey = key;
    });
  }

  // Fetches the list of admins from your Django AdminViewSet
  Future<void> _fetchAdmins() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      // Assumes you have an `fetchAdmins` method in your ApiService
      final adminList = await _apiService.fetchAdmins();
      if (mounted) {
        setState(() {
          _admins = adminList;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load admins: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Shows the dialog to create a new admin
  void _showCreateAdminDialog() {
    final TextEditingController usernameController = TextEditingController();
    // Add controllers for email, password etc. as needed by your API

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Admin'),
          content: TextField(
            controller: usernameController,
            decoration: const InputDecoration(hintText: "Enter username"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Create'),
              onPressed: () async {
                try {
                  final newAdmin = await _apiService.createAdmin({
                    'username': usernameController.text,
                    // Add other required fields here
                  });
                  Navigator.of(context).pop(); // Close the dialog
                  await _fetchAdmins(); // Refresh the list of admins
                  setState(() {
                    _selectedAdminId = newAdmin.adminId;
                  }); // Auto-select the new admin
                } catch (e) {
                  // You can show an error inside the dialog or after it closes
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create admin: ${e.toString()}'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Handles the final download action
  void _handleDownload() async {
    if (_selectedAdminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an owner admin first!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.generateAndDownloadInstaller(
        apiKey: _serverApiKey!,
        ownerAdminId: _selectedAdminId!,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File saved successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download Installer')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // This Dropdown now includes the "Create New" option
                    DropdownButtonFormField<String>(
                      value: _selectedAdminId,
                      hint: const Text('Select Owner Admin'),
                      isExpanded: true,
                      items: [
                        // The special item to trigger the creation dialog
                        const DropdownMenuItem(
                          value: CREATE_NEW_ADMIN_VALUE,
                          child: Row(
                            children: [
                              Icon(Icons.add, color: Colors.blueAccent),
                              SizedBox(width: 8),
                              Text(
                                'Create New Admin...',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // A visual separator
                        if (_admins.isNotEmpty)
                          const DropdownMenuItem(
                            enabled: false,
                            child: Divider(),
                          ),
                        // The list of existing admins fetched from the API
                        ..._admins.map((Admin admin) {
                          return DropdownMenuItem<String>(
                            value: admin.adminId,
                            child: Text(admin.username!),
                          );
                        }).toList(),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue == CREATE_NEW_ADMIN_VALUE) {
                          // If the user selects "Create New", show the dialog
                          _showCreateAdminDialog();
                        } else {
                          // Otherwise, update the state with the selected admin's ID
                          setState(() {
                            _selectedAdminId = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 30),
                    // The download button's state depends on loading and selection
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.download),
                            label: const Text('Generate & Download'),
                            onPressed: _selectedAdminId == null
                                ? null
                                : _handleDownload,
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
