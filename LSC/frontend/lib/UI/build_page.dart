// import 'dart:io';
// import 'dart:async';
// import 'package:fluent_ui/fluent_ui.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:frontend/services/api_service.dart'; // Adjust if needed

// class BuildPage extends StatefulWidget {
//   const BuildPage({super.key});

//   @override
//   _BuildPageState createState() => _BuildPageState();
// }

// class _BuildPageState extends State<BuildPage> {
//   final ApiService _apiService = ApiService();

//   // Build state management
//   bool _isBuilding = false;
//   bool _isDownloading = false;
//   String? _buildId;
//   String? _message;
//   String? _errorMessage;
//   double _progress = 0.0;
//   String _currentStage = '';
//   Timer? _statusTimer;

//   // Build stages for better UX
//   final List<String> _buildStages = [
//     'Updating settings',
//     'Building backend',
//     'Copying files',
//     'Building Flutter app',
//     'Creating installer',
//     'Completed',
//   ];

//   @override
//   void dispose() {
//     _statusTimer?.cancel();
//     super.dispose();
//   }

//   /// Get device information (UUID and IP)
//   Future<Map<String, String>> _getDeviceInfo() async {
//     try {
//       // Get BIOS UUID using Process.run to capture output
//       final uuidResult = await Process.run('powershell', [
//         '-Command',
//         '(Get-WmiObject -Class Win32_ComputerSystemProduct).UUID',
//       ]);

//       String uuid = uuidResult.stdout.toString().trim();

//       // Get local IPv4 address
//       List<NetworkInterface> interfaces = await NetworkInterface.list(
//         type: InternetAddressType.IPv4,
//         includeLoopback: false,
//       );

//       String? ip;
//       for (var interface in interfaces) {
//         for (var addr in interface.addresses) {
//           if (!addr.address.startsWith('169.254')) {
//             // Skip link-local
//             ip = addr.address;
//             break;
//           }
//         }
//         if (ip != null) break;
//       }

//       return {'uuid': uuid, 'ip': ip ?? '127.0.0.1'};
//     } catch (e) {
//       // Fallback values if detection fails
//       return {'uuid': 'UNKNOWN-UUID', 'ip': '127.0.0.1'};
//     }
//   }

//   /// Start the build process
//   Future<void> _startBuild() async {
//     setState(() {
//       _isBuilding = true;
//       _message = null;
//       _errorMessage = null;
//       _progress = 0.0;
//       _currentStage = 'Preparing build...';
//     });

//     try {
//       // Get system UUID and IP address
//       final deviceInfo = await _getDeviceInfo();
//       final parentServerId = deviceInfo['uuid']!;
//       final parentServerIp = deviceInfo['ip']!;

//       setState(() {
//         _currentStage = 'Starting build process...';
//         _progress = 0.1;
//       });

//       // Start the build
//       final response = await _apiService.startBuild(
//         parentServerId: parentServerId,
//         parentServerIp: parentServerIp,
//       );

//       setState(() {
//         _buildId = response.buildId;
//         _message = response.message;
//         _currentStage = 'Build started successfully';
//         _progress = 0.2;
//       });

//       // Start monitoring build progress
//       _startProgressMonitoring();
//     } catch (e) {
//       setState(() {
//         _isBuilding = false;
//         _errorMessage = 'Failed to start build: $e';
//         _currentStage = 'Build failed';
//         _progress = 0.0;
//       });
//     }
//   }

//   /// Monitor build progress with periodic status checks
//   void _startProgressMonitoring() {
//     if (_buildId == null) return;

//     _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
//       try {
//         final status = await _apiService.getBuildStatus(_buildId!);

//         setState(() {
//           _progress = status.progress / 100.0;
//           _currentStage = status.message;

//           // Update stage description based on progress
//           if (status.progress < 20) {
//             _currentStage = 'Updating settings...';
//           } else if (status.progress < 40) {
//             _currentStage = 'Building backend...';
//           } else if (status.progress < 60) {
//             _currentStage = 'Copying files...';
//           } else if (status.progress < 80) {
//             _currentStage = 'Building Flutter app...';
//           } else if (status.progress < 100) {
//             _currentStage = 'Creating installer...';
//           } else {
//             _currentStage = 'Build completed!';
//           }

//           if (status.status == 'completed') {
//             _isBuilding = false;
//             _message = 'Build completed successfully! Ready for download.';
//             timer.cancel();
//           } else if (status.status == 'failed') {
//             _isBuilding = false;
//             _errorMessage = 'Build failed: ${status.message}';
//             timer.cancel();
//           }
//         });
//       } catch (e) {
//         setState(() {
//           _isBuilding = false;
//           _errorMessage = 'Error monitoring build: $e';
//         });
//         timer.cancel();
//       }
//     });
//   }

//   /// Download the build installer
//   Future<void> _downloadBuild() async {
//     if (_buildId == null || _isDownloading) return;

//     setState(() {
//       _isDownloading = true;
//       _currentStage = 'Downloading installer...';
//     });

//     try {
//       // Get downloads directory
//       final directory = await getDownloadsDirectory();
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final fileName = 'Bluck_Security_$timestamp.exe';
//       final filePath = '${directory?.path ?? ''}/$fileName';

//       await _apiService.downloadBuild(_buildId!, filePath);

//       setState(() {
//         _isDownloading = false;
//         _message = 'Downloaded successfully!\nLocation: $filePath';
//         _currentStage = 'Download completed';
//       });

//       // Show success message
//       _showSuccessDialog('Download Complete', 'Installer saved to:\n$filePath');
//     } catch (e) {
//       setState(() {
//         _isDownloading = false;
//         _errorMessage = 'Download failed: $e';
//         _currentStage = 'Download failed';
//       });
//     }
//   }

//   /// Launch download in browser (alternative download method)
//   Future<void> _launchDownload() async {
//     if (_buildId == null) return;

//     try {
//       await _apiService.launchBuildDownload(_buildId!);
//       setState(() {
//         _message = 'Download started in your browser';
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to launch download: $e';
//       });
//     }
//   }

//   /// Show success dialog
//   void _showSuccessDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (context) => ContentDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           Button(
//             child: const Text('OK'),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Get progress color based on status
//   Color _getProgressColor() {
//     if (_errorMessage != null) return Colors.red;
//     if (_progress >= 1.0) return Colors.green;
//     return Colors.blue;
//   }

//   /// Get status icon
//   Widget _getStatusIcon() {
//     if (_errorMessage != null) {
//       return Icon(FluentIcons.error_badge, color: Colors.red, size: 24);
//     }
//     if (_progress >= 1.0 && !_isBuilding) {
//       return Icon(FluentIcons.completed_solid, color: Colors.green, size: 24);
//     }
//     if (_isBuilding || _isDownloading) {
//       return const SizedBox(
//         width: 24,
//         height: 24,
//         child: ProgressRing(strokeWidth: 2),
//       );
//     }
//     return Icon(FluentIcons.build_queue, color: Colors.grey, size: 24);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Header Card
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         FluentIcons.build_queue,
//                         size: 28,
//                         color: Colors.blue,
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         'D-SEC Installer Builder',
//                         style: FluentTheme.of(context).typography.titleLarge,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Build a custom installer with your device configuration',
//                     style: FluentTheme.of(context).typography.body,
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 20),

//           // Build Button
//           SizedBox(
//             height: 50,
//             child: Button(
//               onPressed: (_isBuilding || _isDownloading) ? null : _startBuild,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (_isBuilding)
//                     const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: ProgressRing(strokeWidth: 2),
//                     )
//                   else
//                     Icon(FluentIcons.build_queue),
//                   const SizedBox(width: 8),
//                   Text(_isBuilding ? 'Building...' : 'Start Build'),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Progress Card (shown when building or completed)
//           if (_isBuilding || _buildId != null) ...[
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         _getStatusIcon(),
//                         const SizedBox(width: 12),
//                         Text(
//                           'Build Progress',
//                           style: FluentTheme.of(context).typography.subtitle,
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 16),

//                     // Progress Bar
//                     ProgressBar(
//                       value: _progress * 100,
//                       backgroundColor: Colors.grey.withOpacity(0.3),
//                     ),

//                     const SizedBox(height: 8),

//                     Text(
//                       '${(_progress * 100).toInt()}% Complete',
//                       style: FluentTheme.of(context).typography.caption,
//                     ),

//                     const SizedBox(height: 16),

//                     // Current Status
//                     Text(
//                       'Status: $_currentStage',
//                       style: FluentTheme.of(context).typography.body,
//                     ),

//                     if (_buildId != null) ...[
//                       const SizedBox(height: 8),
//                       Text(
//                         'Build ID: $_buildId',
//                         style: FluentTheme.of(context).typography.caption,
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),
//           ],

//           // Success/Error Messages
//           if (_message != null) ...[
//             InfoBar(
//               title: const Text('Success'),
//               content: Text(_message!),
//               severity: InfoBarSeverity.success,
//             ),
//             const SizedBox(height: 16),
//           ],

//           if (_errorMessage != null) ...[
//             InfoBar(
//               title: const Text('Error'),
//               content: Text(_errorMessage!),
//               severity: InfoBarSeverity.error,
//             ),
//             const SizedBox(height: 16),
//           ],

//           // Download Buttons (shown when build is complete)
//           if (_progress >= 1.0 && !_isBuilding && _buildId != null) ...[
//             Row(
//               children: [
//                 Expanded(
//                   child: SizedBox(
//                     height: 50,
//                     child: Button(
//                       onPressed: _isDownloading ? null : _downloadBuild,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           if (_isDownloading)
//                             const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: ProgressRing(strokeWidth: 2),
//                             )
//                           else
//                             Icon(FluentIcons.download),
//                           const SizedBox(width: 8),
//                           Text(
//                             _isDownloading
//                                 ? 'Downloading...'
//                                 : 'Download to Device',
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: SizedBox(
//                     height: 50,
//                     child: Button(
//                       onPressed: _launchDownload,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(FluentIcons.globe),
//                           const SizedBox(width: 8),
//                           const Text('Open in Browser'),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],

//           const SizedBox(height: 10),

//           // Build Information Card
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Build Information',
//                     style: FluentTheme.of(context).typography.subtitle,
//                   ),
//                   const SizedBox(height: 12),
//                   _buildInfoRow('Auto-detected Server ID', 'From system UUID'),
//                   _buildInfoRow(
//                     'Auto-detected Server IP',
//                     'From network interface',
//                   ),
//                   _buildInfoRow(
//                     'Build Service',
//                     "http://127.0.0.1:5000", //'${_apiService._buildServiceUrl}',
//                   ),
//                   _buildInfoRow('Output Format', 'Bluck_Security.exe'),
//                 ],
//               ),
//             ),
//           ),

//           // Instructions Card
//           const SizedBox(height: 16),
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(FluentIcons.info, color: Colors.blue),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Instructions',
//                         style: FluentTheme.of(context).typography.subtitle,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     '1. Click "Start Build" to begin the automated build process\n'
//                     '2. Monitor the real-time progress as the installer is created\n'
//                     '3. Download the finished installer when build completes\n'
//                     '4. The installer will be automatically configured for this device',
//                     style: FluentTheme.of(context).typography.body,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Helper method to create info rows
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 140,
//             child: Text(
//               '$label:',
//               style: FluentTheme.of(context).typography.caption,
//             ),
//           ),
//           Expanded(
//             child: Text(value, style: FluentTheme.of(context).typography.body),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:frontend/services/api_service.dart'; // Adjust if needed

class BuildPage extends StatefulWidget {
  const BuildPage({super.key});

  @override
  _BuildPageState createState() => _BuildPageState();
}

class _BuildPageState extends State<BuildPage> {
  final ApiService _apiService = ApiService();

  // Build state management
  bool _isBuilding = false;
  bool _isDownloading = false;
  String? _buildId;
  String? _message;
  String? _errorMessage;
  double _progress = 0.0;
  String _currentStage = '';
  Timer? _statusTimer;

  // Build stages for better UX
  final List<String> _buildStages = [
    'Updating settings',
    'Building backend',
    'Copying files',
    'Building Flutter app',
    'Creating installer',
    'Completed',
  ];

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  /// Get device information (UUID and IP)
  Future<Map<String, String>> _getDeviceInfo() async {
    try {
      // Get BIOS UUID using Process.run to capture output
      final uuidResult = await Process.run('powershell', [
        '-Command',
        '(Get-WmiObject -Class Win32_ComputerSystemProduct).UUID',
      ]);

      String uuid = uuidResult.stdout.toString().trim();

      // Get local IPv4 address
      List<NetworkInterface> interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );

      String? ip;
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.address.startsWith('169.254')) {
            // Skip link-local
            ip = addr.address;
            break;
          }
        }
        if (ip != null) break;
      }

      return {'uuid': uuid, 'ip': ip ?? '127.0.0.1'};
    } catch (e) {
      // Fallback values if detection fails
      return {'uuid': 'UNKNOWN-UUID', 'ip': '127.0.0.1'};
    }
  }

  /// Start the build process
  Future<void> _startBuild() async {
    setState(() {
      _isBuilding = true;
      _message = null;
      _errorMessage = null;
      _progress = 0.0;
      _currentStage = 'Preparing build...';
    });

    try {
      // Get system UUID and IP address
      final deviceInfo = await _getDeviceInfo();
      final parentServerId = deviceInfo['uuid']!;
      final parentServerIp = deviceInfo['ip']!;

      setState(() {
        _currentStage = 'Starting build process...';
        _progress = 0.1;
      });

      // Start the build
      final response = await _apiService.startBuild(
        parentServerId: parentServerId,
        parentServerIp: parentServerIp,
      );

      setState(() {
        _buildId = response.buildId;
        _message = response.message;
        _currentStage = 'Build started successfully';
        _progress = 0.2;
      });

      // Start monitoring build progress
      _startProgressMonitoring();
    } catch (e) {
      setState(() {
        _isBuilding = false;
        _errorMessage = 'Failed to start build: $e';
        _currentStage = 'Build failed';
        _progress = 0.0;
      });
    }
  }

  /// Monitor build progress with periodic status checks
  void _startProgressMonitoring() {
    if (_buildId == null) return;

    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final status = await _apiService.getBuildStatus(_buildId!);

        setState(() {
          _progress = status.progress / 100.0;
          _currentStage = status.message;

          // Update stage description based on progress
          if (status.progress < 20) {
            _currentStage = 'Updating settings...';
          } else if (status.progress < 40) {
            _currentStage = 'Building backend...';
          } else if (status.progress < 60) {
            _currentStage = 'Copying files...';
          } else if (status.progress < 80) {
            _currentStage = 'Building Flutter app...';
          } else if (status.progress < 100) {
            _currentStage = 'Creating installer...';
          } else {
            _currentStage = 'Build completed!';
          }

          if (status.status == 'completed') {
            _isBuilding = false;
            _message = 'Build completed successfully! Ready for download.';
            timer.cancel();
          } else if (status.status == 'failed') {
            _isBuilding = false;
            _errorMessage = 'Build failed: ${status.message}';
            timer.cancel();
          }
        });
      } catch (e) {
        setState(() {
          _isBuilding = false;
          _errorMessage = 'Error monitoring build: $e';
        });
        timer.cancel();
      }
    });
  }

  /// Download the build installer
  Future<void> _downloadBuild() async {
    if (_buildId == null || _isDownloading) return;

    setState(() {
      _isDownloading = true;
      _currentStage = 'Downloading installer...';
    });

    try {
      // Get downloads directory
      final directory = await getDownloadsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Bluck_Security_$timestamp.exe';
      final filePath = '${directory?.path ?? ''}/$fileName';

      await _apiService.downloadBuild(_buildId!, filePath);

      setState(() {
        _isDownloading = false;
        _message = 'Downloaded successfully!\nLocation: $filePath';
        _currentStage = 'Download completed';
      });

      // Show success message
      _showSuccessDialog('Download Complete', 'Installer saved to:\n$filePath');
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _errorMessage = 'Download failed: $e';
        _currentStage = 'Download failed';
      });
    }
  }

  /// Launch download in browser (alternative download method)
  Future<void> _launchDownload() async {
    if (_buildId == null) return;

    try {
      await _apiService.launchBuildDownload(_buildId!);
      setState(() {
        _message = 'Download started in your browser';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to launch download: $e';
      });
    }
  }

  /// Show success dialog
  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          Button(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Get progress color based on status
  Color _getProgressColor() {
    if (_errorMessage != null) return Colors.red;
    if (_progress >= 1.0) return Colors.green;
    return Colors.blue;
  }

  /// Get status icon
  Widget _getStatusIcon() {
    if (_errorMessage != null) {
      return Icon(FluentIcons.error_badge, color: Colors.red, size: 24);
    }
    if (_progress >= 1.0 && !_isBuilding) {
      return Icon(FluentIcons.completed_solid, color: Colors.green, size: 24);
    }
    if (_isBuilding || _isDownloading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: ProgressRing(strokeWidth: 2),
      );
    }
    return Icon(FluentIcons.build_queue, color: Colors.grey, size: 24);
  }

  @override
  Widget build(BuildContext context) {
    //
    // **** THE ONLY CHANGE IS HERE ****
    //
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          FluentIcons.build_queue,
                          size: 28,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'D-SEC Installer Builder',
                          style: FluentTheme.of(context).typography.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Build a custom installer with your device configuration',
                      style: FluentTheme.of(context).typography.body,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Build Button
            SizedBox(
              height: 50,
              child: Button(
                onPressed: (_isBuilding || _isDownloading) ? null : _startBuild,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isBuilding)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: ProgressRing(strokeWidth: 2),
                      )
                    else
                      Icon(FluentIcons.build_queue),
                    const SizedBox(width: 8),
                    Text(_isBuilding ? 'Building...' : 'Start Build'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Progress Card (shown when building or completed)
            if (_isBuilding || _buildId != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _getStatusIcon(),
                          const SizedBox(width: 12),
                          Text(
                            'Build Progress',
                            style: FluentTheme.of(context).typography.subtitle,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Progress Bar
                      ProgressBar(
                        value: (_progress * 100).clamp(0.0, 100.0),
                        backgroundColor: Colors.grey.withOpacity(0.3),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '${(_progress * 100).toInt()}% Complete',
                        style: FluentTheme.of(context).typography.caption,
                      ),

                      const SizedBox(height: 16),

                      // Current Status
                      Text(
                        'Status: $_currentStage',
                        style: FluentTheme.of(context).typography.body,
                      ),

                      if (_buildId != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Build ID: $_buildId',
                          style: FluentTheme.of(context).typography.caption,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],

            // Success/Error Messages
            if (_message != null) ...[
              InfoBar(
                title: const Text('Success'),
                content: Text(_message!),
                severity: InfoBarSeverity.success,
              ),
              const SizedBox(height: 16),
            ],

            if (_errorMessage != null) ...[
              InfoBar(
                title: const Text('Error'),
                content: Text(_errorMessage!),
                severity: InfoBarSeverity.error,
              ),
              const SizedBox(height: 16),
            ],

            // Download Buttons (shown when build is complete)
            if (_progress >= 1.0 && !_isBuilding && _buildId != null) ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: Button(
                        onPressed: _isDownloading ? null : _downloadBuild,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isDownloading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: ProgressRing(strokeWidth: 2),
                              )
                            else
                              Icon(FluentIcons.download),
                            const SizedBox(width: 8),
                            Text(
                              _isDownloading
                                  ? 'Downloading...'
                                  : 'Download to Device',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: Button(
                        onPressed: _launchDownload,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FluentIcons.globe),
                            const SizedBox(width: 8),
                            const Text('Open in Browser'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 10),

            // Build Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Build Information',
                      style: FluentTheme.of(context).typography.subtitle,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Auto-detected Server ID',
                      'From system UUID',
                    ),
                    _buildInfoRow(
                      'Auto-detected Server IP',
                      'From network interface',
                    ),
                    _buildInfoRow(
                      'Build Service',
                      "http://127.0.0.1:5000", //'${_apiService._buildServiceUrl}',
                    ),
                    _buildInfoRow('Output Format', 'Bluck_Security.exe'),
                  ],
                ),
              ),
            ),

            // Instructions Card
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(FluentIcons.info, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: FluentTheme.of(context).typography.subtitle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. Click "Start Build" to begin the automated build process\n'
                      '2. Monitor the real-time progress as the installer is created\n'
                      '3. Download the finished installer when build completes\n'
                      '4. The installer will be automatically configured for this device',
                      style: FluentTheme.of(context).typography.body,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to create info rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: FluentTheme.of(context).typography.caption,
            ),
          ),
          Expanded(
            child: Text(value, style: FluentTheme.of(context).typography.body),
          ),
        ],
      ),
    );
  }
}
