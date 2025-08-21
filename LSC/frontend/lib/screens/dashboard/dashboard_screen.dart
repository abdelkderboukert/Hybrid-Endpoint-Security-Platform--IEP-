// import 'package:fluent_ui/fluent_ui.dart';
// import 'package:flutter/material.dart' as matrial;
// import 'package:frontend/services/auth_service.dart';
// import 'package:frontend/screens/auth/login_screen.dart';

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   MyHomePageState createState() => MyHomePageState();
// }

// class MyHomePageState extends State<MyHomePage> {
//   int topIndex = 0;
//   PaneDisplayMode displayMode = PaneDisplayMode.open;

//   // The _NavigationBodyItem is a placeholder widget to display content
//   // for each navigation pane item.
//   // You should define this class in your code.
//   // This is how it should be implemented:
//   final List<NavigationPaneItem> items = [
//     PaneItem(
//       icon: const Icon(FluentIcons.home),
//       title: const Text('Home'),
//       body: FluentApp(
//         home: Center(child: Text('Home Page')),
//         theme: FluentThemeData(brightness: Brightness.dark),
//       ),
//     ),
//     PaneItemSeparator(),
//     PaneItem(
//       icon: const Icon(FluentIcons.issue_tracking),
//       title: const Text('Information Panel'),
//       // infoBadge: const InfoBadge(source: Text('8')),
//       body: const Center(child: Text('Information Panel Page')),
//     ),
//     PaneItem(
//       icon: const Icon(FluentIcons.people),
//       title: const Text('Users'),
//       body: const Center(child: Text('Users Page')),
//     ),
//     PaneItem(
//       icon: const Icon(FluentIcons.devices2),
//       title: const Text('Devices'),
//       body: const Center(child: Text('Devices Page')),
//     ),
//     PaneItemExpander(
//       icon: const Icon(FluentIcons.task_manager),
//       title: const Text('Management'),
//       body: const Center(child: Text('Account Page')),
//       items: [
//         PaneItemHeader(header: const Text('Apps')),
//         PaneItem(
//           icon: const Icon(FluentIcons.admin),
//           title: const Text('Admins'),
//           body: const Center(child: Text('Admin Page')),
//         ),
//         PaneItem(
//           icon: const Icon(FluentIcons.server),
//           title: const Text('Servers'),
//           body: const Center(child: Text('Servers Page')),
//         ),
//         PaneItem(
//           icon: const Icon(FluentIcons.access_logo),
//           title: const Text('Licenses'),
//           body: const Center(child: Text('Licenses Page')),
//         ),
//       ],
//     ),

//     PaneItemExpander(
//       icon: const Icon(FluentIcons.security_group),
//       title: const Text('Security & Monitoring'),
//       body: const Center(child: Text('Security & Monitoring Page')),
//       items: [
//         // PaneItemHeader(header: const Text('Apps')),
//         PaneItem(
//           icon: const Icon(FluentIcons.three_quarter_circle),
//           title: const Text('Threats'),
//           body: const Center(child: Text('Threats Page')),
//         ),
//         PaneItem(
//           icon: const Icon(FluentIcons.assign_policy),
//           title: const Text('Policies'),
//           body: const Center(child: Text('Policies Page')),
//         ),
//         PaneItem(
//           icon: const Icon(FluentIcons.desktop_flow),
//           title: const Text('User Monitoring'),
//           body: const Center(child: Text('User Monitoring Page')),
//         ),
//         PaneItem(
//           icon: const Icon(FluentIcons.data_flow),
//           title: const Text('Data Integrity'),
//           body: const Center(child: Text('Data Integrity Page')),
//         ),
//       ],
//     ),
//   ];

//   String? selected;

//   final cats = <String>[
//     'Abyssinian',
//     'Aegean',
//     'American Bobtail',
//     'American Curl',
//   ];

//   String _data = 'Loading...';

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   Future<void> _fetchData() async {
//     try {
//       final responseData = await AuthService().getAuthenticatedData(
//         'your-protected-endpoint',
//       ); // Replace with your endpoint
//       setState(() {
//         _data = 'Fetched data: ${responseData.toString()}';
//       });
//     } on AuthException {
//       // Access token expired or invalid, show a dialog
//       showContentDialog();
//     } catch (e) {
//       setState(() {
//         _data = 'Error: ${e.toString()}';
//       });
//     }
//   }

//   void showContentDialog() async {
//     showDialog<String>(
//       context: context,
//       builder: (context) => ContentDialog(
//         title: const Text('Session Expired'),
//         content: const Text(
//           'Your session has expired. Do you want to refresh it?',
//         ),
//         actions: [
//           Button(
//             child: const Text('Yes, Refresh'),
//             onPressed: () async {
//               Navigator.pop(context); // Close the dialog
//               final success = await AuthService().refreshToken();
//               if (success) {
//                 matrial.ScaffoldMessenger.of(context).showSnackBar(
//                   const matrial.SnackBar(content: Text('Session refreshed!')),
//                 );
//                 _fetchData(); // Retry fetching data
//               } else {
//                 // Refresh token is also expired or invalid
//                 AuthService().logout();
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   matrial.MaterialPageRoute(
//                     builder: (context) => const LoginScreen(),
//                   ),
//                   (Route<dynamic> route) => false,
//                 );
//               }
//             },
//           ),
//           FilledButton(
//             child: const Text('No, Logout'),
//             onPressed: () {
//               Navigator.pop(context); // Close the dialog
//               AuthService().logout();
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 matrial.MaterialPageRoute(
//                   builder: (context) => const LoginScreen(),
//                 ),
//                 (Route<dynamic> route) => false,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return NavigationView(
//       // appBar: const NavigationAppBar(
//       //   title: Text('NavigationView'),
//       //   automaticallyImplyLeading: false,
//       // ),
//       pane: NavigationPane(
//         selected: topIndex,
//         onItemPressed: (index) {
//           if (index == topIndex) {
//             if (displayMode == PaneDisplayMode.open) {
//               setState(() => displayMode = PaneDisplayMode.compact);
//             } else if (displayMode == PaneDisplayMode.compact) {
//               setState(() => displayMode = PaneDisplayMode.open);
//             }
//           }
//         },
//         onChanged: (index) => setState(() => topIndex = index),
//         displayMode: displayMode,
//         header: Container(
//           padding: const EdgeInsets.only(right: 8.0),
//           child: Center(
//             child: AutoSuggestBox<String>(
//               placeholder: 'Search',
//               items: cats.map((cat) {
//                 return AutoSuggestBoxItem<String>(
//                   value: cat,
//                   label: cat,
//                   onFocusChange: (focused) {
//                     if (focused) {
//                       debugPrint('Focused $cat');
//                     }
//                   },
//                 );
//               }).toList(),
//               onSelected: (item) {
//                 setState(() => selected = item.value);
//               },
//             ),
//           ),
//         ),
//         items: items,
//         footerItems: [
//           PaneItemWidgetAdapter(
//             child: Builder(
//               builder: (context) {
//                 if (NavigationView.of(context).displayMode ==
//                     PaneDisplayMode.compact) {
//                   return const FlutterLogo();
//                 }
//                 return const Row(
//                   children: [
//                     FlutterLogo(),
//                     SizedBox(width: 6.0, height: 2),
//                     Text('This is a custom widget'),
//                   ],
//                 );
//               },
//             ),
//           ),
//           PaneItem(
//             icon: const Icon(FluentIcons.account_management),
//             title: const Text('Accont'),
//             body: const Center(child: Text('Accont Page')),
//           ),
//           PaneItem(
//             icon: const Icon(FluentIcons.settings),
//             title: const Text('Settings'),
//             body: const Center(child: Text('Settings Page')),
//           ),
//           PaneItem(
//             icon: const Icon(FluentIcons.sign_out),
//             title: const Text('Logout'),
//             body:
//                 Container(), // Body can be an empty container as we are navigating away
//             onTap: () async {
//               await AuthService().logout();
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 FluentPageRoute(builder: (context) => const LoginScreen()),
//                 (Route<dynamic> route) => false,
//               );
//             },
//           ),
//           // PaneItemAction(
//           //   icon: const Icon(FluentIcons.add),
//           //   title: const Text('Add New Item'),
//           //   onTap: () {
//           //     setState(() {
//           //       items.add(
//           //         PaneItem(
//           //           icon: const Icon(FluentIcons.new_folder),
//           //           title: const Text('New Item'),
//           //           body: const Center(
//           //             child: Text('This is a newly added Item'),
//           //           ),
//           //         ),
//           //       );
//           //     });
//           //   },
//           // ),
//         ],
//       ),
//     );
//   }
// }

// lib/screens/dashboard/home_page.dart

import 'package:fluent_ui/fluent_ui.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/UI/activation_dialog.dart'; // Make sure to import your new widget

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int topIndex = 0;
  PaneDisplayMode displayMode = PaneDisplayMode.open;
  bool _isLicenseActive = false;
  String _data = 'Loading...';

  final List<NavigationPaneItem> items = [
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
              Text(
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
      body: const Center(child: Text('Home Page')),
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
      body: const Center(child: Text('Users Page')),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.devices2),
      title: const Text('Devices'),
      body: const Center(child: Text('Devices Page')),
    ),
    PaneItemExpander(
      icon: const Icon(FluentIcons.task_manager),
      title: const Text('Management'),
      body: const Center(child: Text('Account Page')),
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
  ];

  @override
  void initState() {
    super.initState();
    _checkLicenseStatus();
  }

  // New method to check license and show dialog if needed
  Future<void> _checkLicenseStatus() async {
    try {
      final isActive = await ApiService().checkLicenseStatus();
      setState(() {
        _isLicenseActive = isActive;
      });
      /*
      change:
        if (isActive) {
          //rest of code
        }
      to:
        if (!isActive) {
          //rest of code
        }

      in production
      
      */
      if (isActive) {
        // Use a post-frame callback to show the dialog after the build method is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showActivationDialog();
        });
      }
    } catch (e) {
      // Handle network or other errors while checking status
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
    // This uses showDialog from 'package:fluent_ui/fluent_ui.dart'
    final bool? activationResult = await showDialog<bool>(
      context: context,
      dismissWithEsc: false, // Prevents closing with Escape key
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (context) => const ActivationDialog(),
    );

    if (activationResult == true) {
      setState(() {
        _isLicenseActive = true;
      });
      // Use InfoBar for a non-disruptive notification
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

        // header: Center(
        //   child: Row(
        //     children: [
        //       Image.asset(
        //         'assets/images/Bluck_securety.png',
        //         width: 100,
        //         height: 100,
        //         fit: BoxFit.contain,
        //       ),
        //       Text(
        //         "Bluck Security",
        //         style: TextStyle(
        //           fontSize: 24.0,
        //           fontWeight: FontWeight.bold,
        //           color: Color.fromARGB(235, 126, 121, 121),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        items: items,
        footerItems: [
          PaneItemExpander(
            icon: const Icon(FluentIcons.account_activity),
            title: const Text('Account'),
            body: const Center(child: Text('Account Page')),
            items: [
              PaneItem(
                icon: const Icon(FluentIcons.account_management),
                title: const Text('Account'),
                body: const Center(child: Text('Accont Page')),
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
