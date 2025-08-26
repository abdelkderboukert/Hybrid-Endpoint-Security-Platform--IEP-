// lib/screens/dashboard/home_page.dart

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as matrial; // Use alias for clarity
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/UI/activation_dialog.dart';
import 'package:frontend/UI/account_page.dart';
import 'package:frontend/UI/user_group_management_page.dart';
// import 'package:frontend/utils/app_navigation_map.dart'; // Import the new map

// The indices are based on the order of items in your NavigationPane,
// including main items and footer items.
class AppNavigation {
  static const Map<String, int> pages = {
    'Home': 1,
    'Information Panel': 2,
    'Users': 3,
    'Devices': 4,
    'Management': 5, // This is an expander
    'Admins': 6,
    'Servers': 7,
    'Licenses': 8,
    'Security & Monitoring': 9, // This is an expander
    'Threats': 10,
    'Policies': 11,
    'User Monitoring': 12,
    'Data Integrity': 13,
    'Account': 14, // The first item in the footer expander
    'Settings': 15,
    'Logout': 16,
  };
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int topIndex = 0;
  PaneDisplayMode displayMode = PaneDisplayMode.open;
  bool _isLicenseActive = false;

  @override
  void initState() {
    super.initState();
    _checkLicenseStatus();
  }

  void _navigateTo(String pageTitle) {
    if (AppNavigation.pages.containsKey(pageTitle)) {
      setState(() {
        topIndex = AppNavigation.pages[pageTitle]!;
      });
    } else {
      matrial.ScaffoldMessenger.of(context).showSnackBar(
        matrial.SnackBar(
          content: Text('Error: Page not found for title "$pageTitle"'),
        ),
      );
    }
  }

  Future<void> _checkLicenseStatus() async {
    try {
      final isActive = await ApiService().checkLicenseStatus();
      if (!mounted) return; // Check if the widget is still in the tree

      setState(() {
        _isLicenseActive = isActive;
      });

      if (!_isLicenseActive) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showActivationDialog();
        });
      }
    } catch (e) {
      if (!mounted) return; // Check if the widget is still in the tree

      // Use a proper logging framework in production
      print('Error checking license status: $e');

      setState(() {
        _isLicenseActive = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showActivationDialog();
      });
    }
  }

  Future<void> _showActivationDialog() async {
    // Check if the dialog is already open
    if (!mounted) return;

    final bool? activationResult = await showDialog<bool>(
      context: context,
      dismissWithEsc: false,
      barrierDismissible: false,
      builder: (context) => const ActivationDialog(),
    );

    if (!mounted) return; // Check again after dialog closes

    if (activationResult == true) {
      setState(() {
        _isLicenseActive = true;
      });
      displayInfoBar(
        context,
        builder: (context, close) {
          return InfoBar(
            title: const Text('Success'),
            content: const Text('License activated successfully!'),
            severity: InfoBarSeverity.success,
            onClose: close,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        selected: topIndex,
        onItemPressed: (index) {
          if (index == topIndex) {
            setState(() {
              if (displayMode == PaneDisplayMode.open) {
                displayMode = PaneDisplayMode.compact;
              } else if (displayMode == PaneDisplayMode.compact) {
                displayMode = PaneDisplayMode.open;
              }
            });
          }
        },
        onChanged: (index) => setState(() => topIndex = index),
        displayMode: displayMode,
        items: [
          PaneItemWidgetAdapter(
            child: Builder(
              builder: (context) {
                if (NavigationView.of(context).displayMode ==
                    PaneDisplayMode.compact) {
                  return Image.asset(
                    'assets/images/Bluck_securety.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.contain,
                  );
                }
                return Row(
                  children: [
                    Image.asset(
                      'assets/images/Bluck_securety.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    const Text(
                      "Bluck Security",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(235, 126, 121, 121),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text('Home'),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Home Page'),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => _navigateTo('Settings'),
                    child: const Text('Go to Settings'),
                  ),
                ],
              ),
            ),
          ),
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.issue_tracking),
            title: const Text('Information Panel'),
            body: const Center(child: Text('Information Panel Page')),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.people),
            title: const Text('Users'),
            body: UserGroupManagementPage(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.devices2),
            title: const Text('Devices'),
            body: const Center(child: Text('Devices Page')),
          ),
          PaneItemExpander(
            icon: const Icon(FluentIcons.task_manager),
            title: const Text('Management'),
            body: const Center(child: Text('Management Page')),
            items: [
              PaneItemHeader(header: const Text('Apps')),
              PaneItem(
                icon: const Icon(FluentIcons.admin),
                title: const Text('Admins'),
                body: const Center(child: Text('Admin Page')),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.server),
                title: const Text('Servers'),
                body: const Center(child: Text('Servers Page')),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.access_logo),
                title: const Text('Licenses'),
                body: const Center(child: Text('Licenses Page')),
              ),
            ],
          ),
          PaneItemExpander(
            icon: const Icon(FluentIcons.security_group),
            title: const Text('Security & Monitoring'),
            body: const Center(child: Text('Security & Monitoring Page')),
            items: [
              PaneItem(
                icon: const Icon(FluentIcons.three_quarter_circle),
                title: const Text('Threats'),
                body: const Center(child: Text('Threats Page')),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.assign_policy),
                title: const Text('Policies'),
                body: const Center(child: Text('Policies Page')),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.desktop_flow),
                title: const Text('User Monitoring'),
                body: const Center(child: Text('User Monitoring Page')),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.data_flow),
                title: const Text('Data Integrity'),
                body: const Center(child: Text('Data Integrity Page')),
              ),
            ],
          ),
        ],
        footerItems: [
          PaneItemExpander(
            icon: const Icon(FluentIcons.account_activity),
            title: const Text('Account'),
            body: const Center(child: Text('Account Page')),
            items: [
              PaneItem(
                icon: const Icon(FluentIcons.account_management),
                title: const Text('Account'),
                body: AccountPage(),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.settings),
                title: const Text('Settings'),
                body: const Center(child: Text('Settings Page')),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.sign_out),
                title: const Text('Logout'),
                body: Container(),
                onTap: () async {
                  await AuthService().logout();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    FluentPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

