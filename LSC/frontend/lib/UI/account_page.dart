// lib/screens/dashboard/account_page.dart

import 'package:fluent_ui/fluent_ui.dart';
import 'package:frontend/models/models.dart';
import 'package:frontend/services/api_service.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Admin?>(
      future: ApiService().getAdminProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: ProgressRing());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data != null) {
          final admin = snapshot.data!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Information',
                style: FluentTheme.of(context).typography.title,
              ),
              const SizedBox(height: 20),
              Text('Username: ${admin.username}'),
              Text('Email: ${admin.email}'),
              Text('License Active: ${admin.isActive == true ? 'Yes' : 'No'}'),
              Text('Layer: ${admin.layer}'),
              Text(
                'Date Joined: ${admin.dateJoined?.toLocal().toString().split(' ')[0]}',
              ),
              // Add more details as needed from your Admin model
            ],
          );
        } else {
          return const Center(child: Text('No profile data found.'));
        }
      },
    );
  }
}
