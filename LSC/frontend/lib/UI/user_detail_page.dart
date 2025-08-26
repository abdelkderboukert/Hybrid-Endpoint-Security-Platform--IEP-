// // lib/UI/user_detail_page.dart

// import 'package:fluent_ui/fluent_ui.dart';
// import '../models/models.dart';

// class UserDetailPage extends StatelessWidget {
//   final User user;

//   const UserDetailPage({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     return ScaffoldPage(
//       header: PageHeader(
//         title: Text('User Details: ${user.username}'),
//         commandBar: Row(
//           children: [
//             // Back button
//             FilledButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Back'),
//             ),
//           ],
//         ),
//       ),
//       content: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'User Information',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//             ),
//             const SizedBox(height: 10),
//             Text('User ID: ${user.userId ?? 'N/A'}'),
//             const SizedBox(height: 5),
//             Text('Username: ${user.username ?? 'N/A'}'),
//             const SizedBox(height: 5),
//             Text('Email: ${user.email ?? 'N/A'}'),
//             const SizedBox(height: 5),
//             Text(
//               'Associated Devices: ${user.associatedDeviceIds?.join(', ') ?? 'None'}',
//             ),
//             const SizedBox(height: 5),
//             Text('Groups: ${user.groups?.join(', ') ?? 'None'}'),
//             const SizedBox(height: 20),
//             const Text(
//               'Synchronization Details',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//             ),
//             const SizedBox(height: 10),
//             Text('Last Modified: ${user.lastModified?.toLocal() ?? 'N/A'}'),
//             const SizedBox(height: 5),
//             Text('Version: ${user.version ?? 'N/A'}'),
//           ],
//         ),
//       ),
//     );
//   }
// }


// lib/UI/user_detail_page.dart

import 'package:fluent_ui/fluent_ui.dart';
import '../models/models.dart';

class UserDetailPage extends StatelessWidget {
  final User user;
  final VoidCallback onGoBack;

  const UserDetailPage({
    super.key,
    required this.user,
    required this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text('User Details: ${user.username}'),
        commandBar: Row(
          children: [
            FilledButton(
              onPressed: onGoBack,
              child: const Text('Back'),
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text('User ID: ${user.userId ?? 'N/A'}'),
            const SizedBox(height: 5),
            Text('Username: ${user.username ?? 'N/A'}'),
            const SizedBox(height: 5),
            Text('Email: ${user.email ?? 'N/A'}'),
            const SizedBox(height: 5),
            Text('Associated Devices: ${user.associatedDeviceIds?.join(', ') ?? 'None'}'),
            const SizedBox(height: 5),
            Text('Groups: ${user.groups?.join(', ') ?? 'None'}'),
            const SizedBox(height: 20),
            const Text(
              'Synchronization Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text('Last Modified: ${user.lastModified?.toLocal() ?? 'N/A'}'),
            const SizedBox(height: 5),
            Text('Version: ${user.version ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}