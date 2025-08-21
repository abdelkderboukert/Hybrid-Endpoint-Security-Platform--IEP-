// screens/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import './auth/activation_page.dart';
import './dashboard/dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ApiService().checkLicenseStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.data == true) {
          return const MyHomePage();
        } else {
          return const MyHomePage(); //ActivationPage()
        }
      },
    );
  }
}
