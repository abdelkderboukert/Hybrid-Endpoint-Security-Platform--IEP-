// // lib/UI/group_members_page.dart

// import 'package:fluent_ui/fluent_ui.dart';
// import '../models/models.dart';
// import '../services/api_service.dart';
// import 'user_detail_page.dart'; // Import the user detail page

// class GroupMembersPage extends StatefulWidget {
//   final String groupId;
//   final String groupName;

//   const GroupMembersPage({
//     super.key,
//     required this.groupId,
//     required this.groupName,
//   });

//   @override
//   State<GroupMembersPage> createState() => _GroupMembersPageState();
// }

// class _GroupMembersPageState extends State<GroupMembersPage> {
//   final ApiService apiService = ApiService();
//   late Future<List<User>> _groupMembersFuture;

//   @override
//   void initState() {
//     super.initState();
//     _groupMembersFuture = apiService.fetchUsersByGroup(widget.groupId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ScaffoldPage(
//       header: PageHeader(
//         title: Text('Users in Group: ${widget.groupName}'),
//         commandBar: Row(
//           children: [
//             // Example of a back button
//             FilledButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Back'),
//             ),
//           ],
//         ),
//       ),
//       content: FutureBuilder<List<User>>(
//         future: _groupMembersFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: ProgressRing());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No users in this group.'));
//           } else {
//             final List<User> users = snapshot.data!;
//             return ListView.builder(
//               itemCount: users.length,
//               itemBuilder: (context, index) {
//                 final user = users[index];
//                 return ListTile(
//                   title: Text(user.username ?? 'N/A'),
//                   subtitle: Text(user.email ?? 'N/A'),
//                   trailing: const Icon(FluentIcons.chevron_right),
//                   onPressed: () {
//                     // Navigate to user detail page
//                     Navigator.push(
//                       context,
//                       FluentPageRoute(
//                         builder: (context) => UserDetailPage(user: user),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }


// lib/UI/group_members_page.dart

import 'package:fluent_ui/fluent_ui.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'user_detail_page.dart';

class GroupMembersPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final Function(Widget) onNavigate;
  final VoidCallback onGoBack;

  const GroupMembersPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.onNavigate,
    required this.onGoBack,
  });

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  final ApiService apiService = ApiService();
  late Future<List<User>> _groupMembersFuture;

  @override
  void initState() {
    super.initState();
    _groupMembersFuture = apiService.fetchUsersByGroup(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text('Users in Group: ${widget.groupName}'),
        commandBar: Row(
          children: [
            FilledButton(
              onPressed: widget.onGoBack,
              child: const Text('Back'),
            ),
          ],
        ),
      ),
      content: FutureBuilder<List<User>>(
        future: _groupMembersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: ProgressRing());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users in this group.'));
          } else {
            final List<User> users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.username ?? 'N/A'),
                  subtitle: Text(user.email ?? 'N/A'),
                  trailing: const Icon(FluentIcons.chevron_right),
                  onPressed: () {
                    widget.onNavigate(UserDetailPage(
                      user: user,
                      onGoBack: widget.onGoBack, // This will take you back to GroupMembersPage
                    ));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}