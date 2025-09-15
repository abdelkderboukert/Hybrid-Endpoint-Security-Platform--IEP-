// // lib/UI/build_page.dart

// import 'package:fluent_ui/fluent_ui.dart'; // Make sure this is imported
// import 'package:frontend/services/api_service.dart';
// import 'package:frontend/models/models.dart';
// import 'package:frontend/main.dart';

// class BuildPage extends StatefulWidget {
//   const BuildPage({super.key});

//   @override
//   _BuildPageState createState() => _BuildPageState();
// }

// class _BuildPageState extends State<BuildPage> {
//   final ApiService _apiService = ApiService();

//   bool _isLoading = true;
//   List<Admin> _admins = [];
//   String? _selectedAdminId;
//   String? _serverApiKey;
//   String? _error;

//   static const String CREATE_NEW_ADMIN_VALUE = 'CREATE_NEW';

//   @override
//   void initState() {
//     super.initState();
//     _loadApiKey();
//     _fetchAdmins();
//   }

//   void _loadApiKey() {
//     _serverApiKey = env['LSC_API_KEY'];
//   }

//   Future<void> _fetchAdmins() async {
//     // ... (This method remains the same, as it sets an error string instead of showing a notification)
//     if (!mounted) return;
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });
//     try {
//       final adminList = await _apiService.fetchAdmins();
//       if (!mounted) return;
//       setState(() {
//         _admins = adminList;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _error = 'Failed to load admins: ${e.toString()}';
//       });
//     } finally {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showCreateAdminDialog(BuildContext scaffoldContext) {
//     final TextEditingController usernameController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return ContentDialog(
//           // Use ContentDialog for a Fluent look
//           title: const Text('Create New Admin'),
//           content: TextBox(
//             // Use TextBox instead of TextField
//             controller: usernameController,
//             placeholder: 'Enter username',
//           ),
//           actions: [
//             Button(
//               child: const Text('Cancel'),
//               onPressed: () => Navigator.of(dialogContext).pop(),
//             ),
//             FilledButton(
//               // Use FilledButton for the primary action
//               child: const Text('Create'),
//               onPressed: () async {
//                 try {
//                   final newAdmin = await _apiService.createAdmin({
//                     'username': usernameController.text,
//                   });
//                   if (!mounted) return;
//                   Navigator.of(dialogContext).pop();
//                   await _fetchAdmins();
//                   if (!mounted) return;
//                   setState(() {
//                     _selectedAdminId = newAdmin.adminId;
//                   });
//                 } catch (e) {
//                   if (!mounted) return;
//                   // FIX: Use displayInfoBar for the error message
//                   displayInfoBar(
//                     scaffoldContext,
//                     builder: (context, close) {
//                       return InfoBar(
//                         title: const Text('Error'),
//                         content: Text(
//                           'Failed to create admin: ${e.toString()}',
//                         ),
//                         severity: InfoBarSeverity.error,
//                         onClose: close,
//                       );
//                     },
//                   );
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _handleDownload(BuildContext scaffoldContext) async {
//     if (_serverApiKey == null || _selectedAdminId == null) {
//       // FIX: Use displayInfoBar
//       displayInfoBar(
//         scaffoldContext,
//         builder: (context, close) {
//           return InfoBar(
//             title: const Text('Missing Information'),
//             content: const Text(
//               'API Key must be loaded and an admin must be selected.',
//             ),
//             severity: InfoBarSeverity.warning,
//             onClose: close,
//           );
//         },
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await _apiService.generateAndDownloadInstaller(
//         apiKey: _serverApiKey!,
//         ownerAdminId: _selectedAdminId!,
//       );

//       if (!mounted) return;
//       // FIX: Use displayInfoBar for the success message
//       displayInfoBar(
//         scaffoldContext,
//         builder: (context, close) {
//           return InfoBar(
//             title: const Text('Success!'),
//             content: const Text('File saved to your Downloads folder.'),
//             severity: InfoBarSeverity.success,
//             onClose: close,
//           );
//         },
//       );
//     } catch (e) {
//       if (!mounted) return;
//       // FIX: Use displayInfoBar for the error message
//       displayInfoBar(
//         scaffoldContext,
//         builder: (context, close) {
//           return InfoBar(
//             title: const Text('Error'),
//             content: Text('Download failed: ${e.toString()}'),
//             severity: InfoBarSeverity.error,
//             onClose: close,
//           );
//         },
//       );
//     } finally {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // The main page structure remains the same
//     return ScaffoldPage(
//       // Use ScaffoldPage for Fluent UI
//       header: const PageHeader(title: Text('Download Installer')),
//       content: Builder(
//         builder: (scaffoldContext) {
//           if (_isLoading) {
//             return const Center(child: ProgressRing()); // Use ProgressRing
//           }
//           if (_error != null) {
//             return Center(
//               child: Text(_error!, style: TextStyle(color: Colors.red)),
//             );
//           }
//           return Center(
//             child: SizedBox(
//               // Constrain the width for better layout
//               width: 400,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ComboBox<String>(
//                     // Use ComboBox, the Fluent equivalent
//                     value: _selectedAdminId,
//                     placeholder: const Text('Select Owner Admin'),
//                     isExpanded: true,
//                     items: [
//                       ComboBoxItem(
//                         value: CREATE_NEW_ADMIN_VALUE,
//                         child: Row(
//                           children: [
//                             const Icon(FluentIcons.add),
//                             const SizedBox(width: 8),
//                             Text(
//                               'Create New Admin...',
//                               style: TextStyle(
//                                 color: Colors.blue,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       if (_admins.isNotEmpty)
//                         const ComboBoxItem(value: null, child: Divider()),
//                       ..._admins.map((Admin admin) {
//                         return ComboBoxItem<String>(
//                           value: admin.adminId,
//                           child: Text(admin.username!),
//                         );
//                       }).toList(),
//                     ],
//                     onChanged: (String? newValue) {
//                       if (newValue == CREATE_NEW_ADMIN_VALUE) {
//                         _showCreateAdminDialog(scaffoldContext);
//                       } else {
//                         setState(() {
//                           _selectedAdminId = newValue;
//                         });
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 30),
//                   FilledButton(
//                     // Use FilledButton
//                     child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(FluentIcons.download),
//                         SizedBox(width: 8),
//                         Text('Generate & Download'),
//                       ],
//                     ),
//                     onPressed: _selectedAdminId == null
//                         ? null
//                         : () => _handleDownload(scaffoldContext),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// lib/UI/build_page.dart

import 'package:fluent_ui/fluent_ui.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/models.dart';
import 'package:frontend/main.dart';

class BuildPage extends StatefulWidget {
  const BuildPage({super.key});

  @override
  BuildPageState createState() => BuildPageState();
}

class BuildPageState extends State<BuildPage> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  List<Admin> _admins = [];
  Admin? _currentAdmin; // This state variable holds the current admin's profile
  String? _selectedAdminId;
  String? _serverApiKey;
  String? _error;

  static const String kCreateNewAdminValue = 'CREATE_NEW';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _serverApiKey = env['LSC_API_KEY'];

      final results = await Future.wait([
        _apiService.fetchAdmins(),
        _apiService.getAdminProfile(),
      ]);

      if (!mounted) return;
      setState(() {
        _admins = results[0] as List<Admin>;
        _currentAdmin = results[1] as Admin?; // The profile is stored here
        if (_currentAdmin == null) {
          _error = "Could not load current admin's profile.";
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load page data: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCreateAdminDialog(BuildContext scaffoldContext) {
    // --- THIS IS THE FIX ---
    // Use the `_currentAdmin` state variable from this class, not from the ApiService.
    if (_currentAdmin == null || _currentAdmin!.layer == null) {
      displayInfoBar(
        scaffoldContext,
        builder: (context, close) => InfoBar(
          title: const Text('Error'),
          content: const Text("Could not determine the current admin's layer."),
          severity: InfoBarSeverity.error,
          onClose: close,
        ),
      );
      return;
    }

    final int newAdminLayer = _currentAdmin!.layer! + 1;
    // --- END OF FIX ---

    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 400),
        title: const Text('Create New Admin'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormBox(
                controller: usernameController,
                placeholder: 'Enter a unique username',
                validator: (text) {
                  if (text == null || text.isEmpty)
                    return 'Username is required';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormBox(
                controller: emailController,
                placeholder: 'Enter a valid email address',
                validator: (text) {
                  if (text == null || !text.contains('@'))
                    return 'A valid email is required';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormBox(
                controller: passwordController,
                placeholder: 'Enter a strong password',
                obscureText: true,
                validator: (text) {
                  if (text == null || text.length < 8)
                    return 'Password must be at least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormBox(
                controller: confirmPasswordController,
                placeholder: 'Re-enter the password',
                obscureText: true,
                validator: (text) {
                  if (text != passwordController.text)
                    return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: 'Admin Layer:',
                child: Text(
                  'This new admin will be created at Layer $newAdminLayer.',
                  style: FluentTheme.of(context).typography.caption,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          StatefulBuilder(
            builder: (context, setDialogState) {
              bool isCreating = false;
              return FilledButton(
                onPressed: isCreating
                    ? null
                    : () async {
                        if (formKey.currentState?.validate() ?? false) {
                          setDialogState(() => isCreating = true);
                          try {
                            final newAdmin = await _apiService.createAdmin({
                              'username': usernameController.text,
                              'email': emailController.text,
                              'password': passwordController.text,
                              'password2': confirmPasswordController.text,
                              'layer': newAdminLayer,
                            });
                            if (!mounted) return;
                            Navigator.of(dialogContext).pop();
                            await _loadInitialData();
                            if (!mounted) return;
                            setState(() => _selectedAdminId = newAdmin.adminId);
                          } catch (e) {
                            if (!mounted) return;
                            displayInfoBar(
                              scaffoldContext,
                              builder: (context, close) => InfoBar(
                                title: const Text('Error'),
                                content: Text(
                                  'Failed to create admin: ${e.toString()}',
                                ),
                                severity: InfoBarSeverity.error,
                                onClose: close,
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setDialogState(() => isCreating = false);
                            }
                          }
                        }
                      },
                child: isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: ProgressRing(strokeWidth: 2.0),
                      )
                    : const Text('Create'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleDownload(BuildContext scaffoldContext) async {
    if (_serverApiKey == null || _selectedAdminId == null) {
      displayInfoBar(
        scaffoldContext,
        builder: (context, close) {
          return InfoBar(
            title: const Text('Missing Information'),
            content: const Text(
              'API Key must be loaded and an admin must be selected.',
            ),
            severity: InfoBarSeverity.warning,
            onClose: close,
          );
        },
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.generateAndDownloadInstaller(
        apiKey: _serverApiKey!,
        ownerAdminId: _selectedAdminId!,
      );
      if (!mounted) return;
      displayInfoBar(
        scaffoldContext,
        builder: (context, close) => InfoBar(
          title: const Text('Success!'),
          content: const Text('File saved to your Downloads folder.'),
          severity: InfoBarSeverity.success,
          onClose: close,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      displayInfoBar(
        scaffoldContext,
        builder: (context, close) => InfoBar(
          title: const Text('Error'),
          content: Text('Download failed: ${e.toString()}'),
          severity: InfoBarSeverity.error,
          onClose: close,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(title: Text('Generate Windows Installer')),
      content: Builder(
        builder: (scaffoldContext) {
          if (_isLoading) {
            return const Center(child: ProgressRing());
          }
          if (_error != null) {
            return Center(
              child: Text(_error!, style: TextStyle(color: Colors.red)),
            );
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: SizedBox(
                  width: 450,
                  child: Card(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configure Installer',
                          style: FluentTheme.of(context).typography.title,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select an owner for this new server installation. You can also create a new admin directly from this screen.',
                          style: FluentTheme.of(context).typography.body,
                        ),
                        const SizedBox(height: 24),
                        ComboBox<String>(
                          value: _selectedAdminId,
                          placeholder: const Text('Select Owner Admin...'),
                          isExpanded: true,
                          items: [
                            const ComboBoxItem(
                              value: kCreateNewAdminValue,
                              child: Row(
                                children: [
                                  Icon(FluentIcons.add),
                                  SizedBox(width: 8),
                                  Text(
                                    'Create New Admin...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_admins.isNotEmpty)
                              const ComboBoxItem(value: null, child: Divider()),
                            ..._admins.map((Admin admin) {
                              return ComboBoxItem<String>(
                                value: admin.adminId,
                                child: Text(admin.username!),
                              );
                            }),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue == kCreateNewAdminValue) {
                              _showCreateAdminDialog(scaffoldContext);
                            } else if (newValue != null) {
                              setState(() => _selectedAdminId = newValue);
                            }
                          },
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed:
                                (_selectedAdminId == null || _isLoading)
                                ? null
                                : () => _handleDownload(scaffoldContext),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: ProgressRing(strokeWidth: 2.5),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(FluentIcons.download),
                                      SizedBox(width: 8),
                                      Text('Generate & Download'),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
