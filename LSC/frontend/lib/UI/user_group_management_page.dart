// // lib/UI/user_group_management_page.dart

// import 'package:fluent_ui/fluent_ui.dart';
// import '../models/models.dart';
// import '../services/api_service.dart';

// /// ViewModel for groups with user counts
// class GroupWithCount {
//   final Group group;
//   final int userCount;

//   GroupWithCount(this.group, this.userCount);
// }

// class UserGroupManagementPage extends StatefulWidget {
//   const UserGroupManagementPage({super.key});

//   @override
//   _UserGroupManagementPageState createState() =>
//       _UserGroupManagementPageState();
// }

// class _UserGroupManagementPageState extends State<UserGroupManagementPage> {
//   final ApiService apiService = ApiService();
//   late Future<List<dynamic>> usersAndGroupsFuture;
//   List<dynamic> allUsersAndGroups = [];
//   List<dynamic> filteredList = [];
//   final TextEditingController searchController = TextEditingController();
//   final Set<String> _selectedIds = {};
//   List<Group> allGroups = [];

//   @override
//   void initState() {
//     super.initState();
//     usersAndGroupsFuture = fetchData();
//     searchController.addListener(onSearchChanged);
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   Future<List<dynamic>> fetchData() async {
//     try {
//       final List<Group> groups = await apiService.fetchGroups();
//       final List<User> unattachedUsers = await apiService
//           .fetchUnattachedUsers();

//       allGroups = groups;

//       final List<GroupWithCount> groupsWithCount = [];
//       for (var group in groups) {
//         final groupUsers = await apiService.fetchUsersByGroup(group.groupId!);
//         groupsWithCount.add(GroupWithCount(group, groupUsers.length));
//       }

//       final List<dynamic> combinedList = [
//         ...groupsWithCount,
//         ...unattachedUsers,
//       ];

//       if (mounted) {
//         setState(() {
//           allUsersAndGroups = combinedList;
//           filteredList = combinedList;
//         });
//       }
//       return combinedList;
//     } catch (e) {
//       if (mounted) {
//         displayInfoBar(
//           context,
//           builder: (context, close) {
//             return InfoBar(
//               title: const Text('Error'),
//               content: Text('Failed to load data: $e'),
//               severity: InfoBarSeverity.error,
//               action: IconButton(
//                 icon: const Icon(FluentIcons.clear),
//                 onPressed: close,
//               ),
//             );
//           },
//         );
//       }
//       rethrow;
//     }
//   }

//   void onSearchChanged() {
//     final query = searchController.text.toLowerCase();
//     setState(() {
//       filteredList = allUsersAndGroups.where((item) {
//         if (item is GroupWithCount) {
//           return item.group.groupName!.toLowerCase().contains(query);
//         } else if (item is User) {
//           return item.username!.toLowerCase().contains(query) ||
//               item.email!.toLowerCase().contains(query);
//         }
//         return false;
//       }).toList();
//     });
//   }

//   void _onSelectionChanged(String id, bool? checked) {
//     setState(() {
//       if (checked == true) {
//         _selectedIds.add(id);
//       } else {
//         _selectedIds.remove(id);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ScaffoldPage(
//       header: const PageHeader(title: Text('Users & Groups')),
//       content: Column(
//         children: [
//           // Search bar
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16.0,
//               vertical: 8.0,
//             ),
//             child: Row(
//               children: [
//                 const Text('Show users:'),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: [
//                         _buildStatusFilter(
//                           'All',
//                           allUsersAndGroups.length,
//                           Colors.blue,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 SizedBox(
//                   width: 200,
//                   child: TextBox(
//                     controller: searchController,
//                     placeholder: 'Search',
//                     suffix: const Icon(FluentIcons.search),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Action bar
//           _buildActionBar(),

//           // Table
//           const Divider(size: 1),
//           _buildTableHeader(),
//           const Divider(size: 1),

//           Expanded(
//             child: FutureBuilder<List<dynamic>>(
//               future: usersAndGroupsFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: ProgressRing());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text('No data found.'));
//                 } else {
//                   return ListView.builder(
//                     itemCount: filteredList.length,
//                     itemBuilder: (context, index) {
//                       final item = filteredList[index];
//                       return _buildTableRow(item);
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusFilter(String title, int count, Color color) {
//     return HyperlinkButton(
//       onPressed: () {},
//       child: Column(
//         children: [
//           Text('$title ($count)', style: TextStyle(color: color)),
//           Container(height: 2, width: 50, color: color),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionBar() {
//     final bool hasSelection = _selectedIds.isNotEmpty;
//     // Check if any selected item is a user
//     final bool isUserSelected =
//         hasSelection &&
//         filteredList.any((item) {
//           final String id;
//           if (item is User) {
//             id = item.userId!;
//           } else if (item is GroupWithCount) {
//             id = item.group.groupId!;
//           } else {
//             return false;
//           }
//           return _selectedIds.contains(id) && item is User;
//         });

//     return CommandBar(
//       primaryItems: [
//         CommandBarButton(
//           icon: const Icon(FluentIcons.add),
//           label: const Text('Add users'),
//           onPressed: () => _showAddUserDialog(),
//         ),
//         CommandBarButton(
//           icon: const Icon(FluentIcons.group),
//           label: const Text('Create group'),
//           onPressed: () => _showCreateGroupDialog(),
//         ),
//         CommandBarButton(
//           icon: const Icon(FluentIcons.folder_open),
//           label: const Text('Move to group'),
//           onPressed: isUserSelected ? () => _showMoveUserDialog() : null,
//         ),
//         CommandBarButton(
//           icon: const Icon(FluentIcons.delete),
//           label: const Text('Delete'),
//           onPressed: hasSelection ? () => _showDeleteDialog() : null,
//         ),
//       ],
//     );
//   }

//   Widget _buildTableHeader() {
//     return const Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Row(
//         children: [
//           Expanded(flex: 1, child: Checkbox(checked: false, onChanged: null)),
//           Expanded(flex: 4, child: Text('User / Group')),
//           Expanded(flex: 2, child: Text('Number of devices / members')),
//           Expanded(flex: 2, child: Text('Comment')),
//           Expanded(flex: 2, child: Text('Access rights')),
//           Expanded(flex: 3, child: Text('Security profile')),
//         ],
//       ),
//     );
//   }

//   Widget _buildTableRow(dynamic item) {
//     final bool isGroup = item is GroupWithCount;
//     final String id = isGroup ? item.group.groupId! : item.userId!;
//     final bool isSelected = _selectedIds.contains(id);

//     final String name = isGroup
//         ? item.group.groupName ?? 'N/A'
//         : item.username ?? 'N/A';
//     final String details = isGroup ? 'Group' : item.email ?? 'N/A';

//     final Widget icon = isGroup
//         ? const Icon(FluentIcons.group)
//         : const Icon(FluentIcons.contact);

//     final int count = isGroup
//         ? item.userCount
//         : (item.associatedDeviceIds?.length ?? 0);

//     return Button(
//       onPressed: () {
//         if (!isGroup) {
//           _showUserDetailDialog(item as User);
//         }
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//         child: Row(
//           children: [
//             Expanded(
//               flex: 1,
//               // child: Checkbox(
//               //   checked: isSelected,
//               //   onChanged: (value) => _onSelectionChanged(id, value),
//               // ),
//               child: Checkbox(
//                 checked: isSelected,
//                 onChanged: (value) => _onSelectionChanged(id, value),
//               ),
//             ),
//             Expanded(flex: 2, child: icon),
//             Expanded(
//               flex: 4,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Text(details, style: const TextStyle(color: Colors.grey)),
//                 ],
//               ),
//             ),
//             Expanded(flex: 2, child: Text('$count')),
//             const Expanded(flex: 2, child: Text('N/A')),
//             const Expanded(flex: 2, child: Text('N/A')),
//             const Expanded(flex: 3, child: Text('Default')),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- Dialogs & Actions ---

//   Future<void> _showAddUserDialog() async {
//     final usernameController = TextEditingController();
//     final emailController = TextEditingController();
//     String? selectedGroupId;

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return ContentDialog(
//               title: const Text('Add New User'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextBox(
//                     controller: usernameController,
//                     placeholder: 'Username',
//                   ),
//                   const SizedBox(height: 10),
//                   TextBox(controller: emailController, placeholder: 'Email'),
//                   const SizedBox(height: 10),

//                   // Use ComboBox for single-group selection on creation
//                   ComboBox<String?>(
//                     placeholder: const Text('Select Group (optional)'),
//                     value: selectedGroupId,
//                     items: allGroups.map((group) {
//                       return ComboBoxItem(
//                         value: group.groupId,
//                         child: Text(group.groupName!),
//                       );
//                     }).toList(),
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         selectedGroupId = newValue;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//               actions: [
//                 Button(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//                 FilledButton(
//                   child: const Text('Add User'),
//                   onPressed: () async {
//                     final userData = {
//                       'username': usernameController.text,
//                       'email': emailController.text,
//                       'groups': selectedGroupId != null
//                           ? [selectedGroupId!]
//                           : [],
//                     };
//                     try {
//                       await apiService.createUser(userData);
//                       if (!mounted) return;
//                       Navigator.pop(context);
//                       refreshData();
//                     } catch (e) {
//                       if (!mounted) return;
//                       displayInfoBar(
//                         context,
//                         builder: (context, close) {
//                           return InfoBar(
//                             title: const Text('Error'),
//                             content: Text('Failed to add user: $e'),
//                             severity: InfoBarSeverity.error,
//                             action: IconButton(
//                               icon: const Icon(FluentIcons.clear),
//                               onPressed: close,
//                             ),
//                           );
//                         },
//                       );
//                     }
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<void> _showCreateGroupDialog() async {
//     final groupNameController = TextEditingController();
//     final descriptionController = TextEditingController();

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return ContentDialog(
//           title: const Text('Create New Group'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextBox(
//                 controller: groupNameController,
//                 placeholder: 'Group Name',
//               ),
//               const SizedBox(height: 10),
//               TextBox(
//                 controller: descriptionController,
//                 placeholder: 'Description',
//               ),
//             ],
//           ),
//           actions: [
//             Button(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             FilledButton(
//               child: const Text('Create'),
//               onPressed: () async {
//                 final groupData = {
//                   'group_name': groupNameController.text,
//                   'description': descriptionController.text,
//                 };
//                 try {
//                   await apiService.createGroup(groupData);
//                   if (!mounted) return;
//                   Navigator.pop(context);
//                   refreshData();
//                 } catch (e) {
//                   if (!mounted) return;
//                   displayInfoBar(
//                     context,
//                     builder: (context, close) {
//                       return InfoBar(
//                         title: const Text('Error'),
//                         content: Text('Failed to create group: $e'),
//                         severity: InfoBarSeverity.error,
//                         action: IconButton(
//                           icon: const Icon(FluentIcons.clear),
//                           onPressed: close,
//                         ),
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

//   Future<void> _showMoveUserDialog() async {
//     String? selectedGroupId;

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return ContentDialog(
//               title: const Text('Move Selected Users'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     'Select a group to move the users to. Selecting "Unattached Users" will remove them from all groups.',
//                   ),
//                   const SizedBox(height: 10),
//                   ComboBox<String?>(
//                     placeholder: const Text('Select a Group'),
//                     value: selectedGroupId,
//                     items: [
//                       // Option to remove users from all groups
//                       const ComboBoxItem(
//                         value: null,
//                         child: Text('Unattached Users'),
//                       ),
//                       ...allGroups.map((group) {
//                         return ComboBoxItem(
//                           value: group.groupId,
//                           child: Text(group.groupName!),
//                         );
//                       }),
//                     ],
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         selectedGroupId = newValue;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//               actions: [
//                 Button(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//                 FilledButton(
//                   child: const Text('Move'),
//                   onPressed: selectedGroupId != null
//                       ? () async {
//                           try {
//                             final List<String> groupList =
//                                 selectedGroupId != null
//                                 ? [selectedGroupId!]
//                                 : [];
//                             for (String userId in _selectedIds) {
//                               // The backend handles the list, so we can send it directly
//                               await apiService.updateUser(userId, {
//                                 'groups': groupList,
//                               });
//                             }
//                             if (!mounted) return;
//                             Navigator.pop(context);
//                             refreshData();
//                           } catch (e) {
//                             if (!mounted) return;
//                             displayInfoBar(
//                               context,
//                               builder: (context, close) {
//                                 return InfoBar(
//                                   title: const Text('Error'),
//                                   content: Text('Failed to move users: $e'),
//                                   severity: InfoBarSeverity.error,
//                                   action: IconButton(
//                                     icon: const Icon(FluentIcons.clear),
//                                     onPressed: close,
//                                   ),
//                                 );
//                               },
//                             );
//                           }
//                         }
//                       : null,
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<void> _showDeleteDialog() async {
//     final bool isUser = filteredList.any((item) {
//       final String id;
//       if (item is User) {
//         id = item.userId!;
//       } else if (item is GroupWithCount) {
//         id = item.group.groupId!;
//       } else {
//         return false;
//       }
//       return _selectedIds.contains(id) && item is User;
//     });

//     final String type = isUser ? 'user(s)' : 'group(s)';

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return ContentDialog(
//           title: Text('Delete $type?'),
//           content: Text(
//             'Are you sure you want to delete the selected $type? This action cannot be undone.',
//           ),
//           actions: [
//             Button(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             FilledButton(
//               child: const Text('Delete'),
//               onPressed: () async {
//                 try {
//                   for (String id in _selectedIds) {
//                     if (isUser) {
//                       await apiService.deleteUser(id);
//                     } else {
//                       await apiService.deleteGroup(id);
//                     }
//                   }
//                   if (!mounted) return;
//                   Navigator.pop(context);
//                   refreshData();
//                 } catch (e) {
//                   if (!mounted) return;
//                   displayInfoBar(
//                     context,
//                     builder: (context, close) {
//                       return InfoBar(
//                         title: const Text('Error'),
//                         content: Text('Failed to delete $type: $e'),
//                         severity: InfoBarSeverity.error,
//                         action: IconButton(
//                           icon: const Icon(FluentIcons.clear),
//                           onPressed: close,
//                         ),
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

//   void _showUserDetailDialog(User user) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return ContentDialog(
//           title: Text(user.username ?? 'User Details'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Username: ${user.username}'),
//               const SizedBox(height: 5),
//               Text('Email: ${user.email}'),
//               const SizedBox(height: 5),
//               Text(
//                 'Number of Devices: ${user.associatedDeviceIds?.length ?? 0}',
//               ),
//               const SizedBox(height: 5),
//               Text('Groups: ${user.groups?.join(', ') ?? 'None'}'),
//             ],
//           ),
//           actions: [
//             Button(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void refreshData() {
//     _selectedIds.clear();
//     setState(() {
//       usersAndGroupsFuture = fetchData();
//     });
//   }
// }

import 'package:fluent_ui/fluent_ui.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ViewModel for groups with user counts
class GroupWithCount {
  final Group group;
  final int userCount;

  GroupWithCount(this.group, this.userCount);
}

class UserGroupManagementPage extends StatefulWidget {
  const UserGroupManagementPage({super.key});

  @override
  _UserGroupManagementPageState createState() =>
      _UserGroupManagementPageState();
}

class _UserGroupManagementPageState extends State<UserGroupManagementPage> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> usersAndGroupsFuture;
  List<dynamic> allUsersAndGroups = [];
  List<dynamic> filteredList = [];
  final TextEditingController searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  List<Group> allGroups = [];

  // Variables for nested navigation
  String? _selectedItemId;
  dynamic _selectedItem;

  @override
  void initState() {
    super.initState();
    usersAndGroupsFuture = fetchData();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> fetchData() async {
    try {
      final List<Group> groups = await apiService.fetchGroups();
      final List<User> unattachedUsers = await apiService
          .fetchUnattachedUsers();

      allGroups = groups;

      final List<GroupWithCount> groupsWithCount = [];
      for (var group in groups) {
        final groupUsers = await apiService.fetchUsersByGroup(group.groupId!);
        groupsWithCount.add(GroupWithCount(group, groupUsers.length));
      }

      final List<dynamic> combinedList = [
        ...groupsWithCount,
        ...unattachedUsers,
      ];

      if (mounted) {
        setState(() {
          allUsersAndGroups = combinedList;
          filteredList = combinedList;
        });
      }
      return combinedList;
    } catch (e) {
      if (mounted) {
        displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Error'),
              content: Text('Failed to load data: $e'),
              severity: InfoBarSeverity.error,
              action: IconButton(
                icon: const Icon(FluentIcons.clear),
                onPressed: close,
              ),
            );
          },
        );
      }
      rethrow;
    }
  }

  void onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredList = allUsersAndGroups.where((item) {
        if (item is GroupWithCount) {
          return item.group.groupName!.toLowerCase().contains(query);
        } else if (item is User) {
          return item.username!.toLowerCase().contains(query) ||
              item.email!.toLowerCase().contains(query);
        }
        return false;
      }).toList();
    });
  }

  void _onSelectionChanged(String id, bool? checked) {
    setState(() {
      if (checked == true) {
        // Check if multiple types are selected
        final isCurrentlyGroup =
            filteredList.firstWhere(
                  (item) =>
                      (item is GroupWithCount && item.group.groupId == id) ||
                      (item is User && item.userId == id),
                  orElse: () => null,
                )
                is GroupWithCount;

        final hasExistingSelection = _selectedIds.isNotEmpty;
        if (hasExistingSelection) {
          final isExistingGroup =
              filteredList.firstWhere(
                    (item) =>
                        (item is GroupWithCount &&
                            item.group.groupId == _selectedIds.first) ||
                        (item is User && item.userId == _selectedIds.first),
                    orElse: () => null,
                  )
                  is GroupWithCount;

          if (isCurrentlyGroup != isExistingGroup) {
            // If the types don't match, show an info bar and don't change selection
            displayInfoBar(
              context,
              builder: (context, close) {
                return InfoBar(
                  title: const Text('Invalid Selection'),
                  content: const Text(
                    'You cannot select users and groups at the same time.',
                  ),
                  severity: InfoBarSeverity.warning,
                  action: IconButton(
                    icon: const Icon(FluentIcons.clear),
                    onPressed: close,
                  ),
                );
              },
            );
          } else {
            _selectedIds.add(id);
          }
        } else {
          _selectedIds.add(id);
        }
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _navigateToDetail(dynamic item) {
    setState(() {
      _selectedItemId = (item is GroupWithCount)
          ? item.group.groupId
          : item.userId;
      _selectedItem = item;
    });
  }

  void _goBackToList() {
    setState(() {
      _selectedIds.clear();
      _selectedItemId = null;
      _selectedItem = null;
    });
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we are in a detail view or list view
    if (_selectedItemId != null) {
      return ScaffoldPage(
        header: PageHeader(
          title: Row(
            children: [
              IconButton(
                icon: const Icon(FluentIcons.back),
                onPressed: _goBackToList,
              ),
              const SizedBox(width: 10),
              Text(
                _selectedItem is GroupWithCount
                    ? (_selectedItem as GroupWithCount).group.groupName!
                    : (_selectedItem as User).username!,
              ),
            ],
          ),
        ),
        content: _selectedItem is GroupWithCount
            ? GroupDetailPage(
                groupId: _selectedItemId!,
                allGroups: allGroups,
                apiService: apiService,
                onBack: _goBackToList,
                refreshData: refreshData,
              )
            : UserDetailPage(
                userId: _selectedItemId!,
                apiService: apiService,
                allGroups: allGroups,
                onBack: _goBackToList,
                refreshData: refreshData,
              ),
      );
    }

    // Default list view
    return ScaffoldPage(
      header: const PageHeader(title: Text('Users & Groups')),
      content: Column(
        children: [
          // Search bar and filters
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                const Text('Show users:'),
                const SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatusFilter(
                          'All',
                          allUsersAndGroups.length,
                          Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 200,
                  child: TextBox(
                    controller: searchController,
                    placeholder: 'Search',
                    suffix: const Icon(FluentIcons.search),
                  ),
                ),
              ],
            ),
          ),

          // Action bar
          _buildActionBar(),

          // Table
          const Divider(size: 1),
          _buildTableHeader(),
          const Divider(size: 1),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: usersAndGroupsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: ProgressRing());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data found.'));
                } else {
                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return _buildTableRow(item);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(String title, int count, Color color) {
    return HyperlinkButton(
      onPressed: () {},
      child: Column(
        children: [
          Text('$title ($count)', style: TextStyle(color: color)),
          Container(height: 2, width: 50, color: color),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    final bool hasSelection = _selectedIds.isNotEmpty;
    final bool isUserSelected =
        hasSelection &&
        filteredList.any((item) {
          final String id;
          if (item is User) {
            id = item.userId!;
          } else if (item is GroupWithCount) {
            id = item.group.groupId!;
          } else {
            return false;
          }
          return _selectedIds.contains(id) && item is User;
        });

    return CommandBar(
      primaryItems: [
        CommandBarButton(
          icon: const Icon(FluentIcons.add),
          label: const Text('Add user'),
          onPressed: () => _showAddUserDialog(),
        ),
        CommandBarButton(
          icon: const Icon(FluentIcons.group),
          label: const Text('Create group'),
          onPressed: () => _showCreateGroupDialog(),
        ),
        CommandBarButton(
          icon: const Icon(FluentIcons.edit),
          label: const Text('Edit'),
          onPressed: _selectedIds.length == 1
              ? () {
                  final selectedItem = filteredList.firstWhere(
                    (item) =>
                        (item is User && item.userId == _selectedIds.first) ||
                        (item is GroupWithCount &&
                            item.group.groupId == _selectedIds.first),
                    orElse: () => null,
                  );
                  if (selectedItem is User) {
                    _showEditUserDialog(selectedItem);
                  } else {
                    // Handle edit group or show a message
                  }
                }
              : null,
        ),
        CommandBarButton(
          icon: const Icon(FluentIcons.folder_open),
          label: const Text('Move to group'),
          onPressed: isUserSelected ? () => _showMoveUserDialog() : null,
        ),
        CommandBarButton(
          icon: const Icon(FluentIcons.delete),
          label: const Text('Delete'),
          onPressed: hasSelection ? () => _showDeleteDialog() : null,
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 1, child: Checkbox(checked: false, onChanged: null)),
          Expanded(flex: 4, child: Text('User / Group')),
          Expanded(flex: 2, child: Text('Number of devices / members')),
          Expanded(flex: 2, child: Text('Comment')),
          Expanded(flex: 2, child: Text('Access rights')),
          Expanded(flex: 3, child: Text('Security profile')),
        ],
      ),
    );
  }

  Widget _buildTableRow(dynamic item) {
    final bool isGroup = item is GroupWithCount;
    final String id = isGroup ? item.group.groupId! : item.userId!;
    final bool isSelected = _selectedIds.contains(id);

    final String name = isGroup
        ? item.group.groupName ?? 'N/A'
        : item.username ?? 'N/A';
    final String details = isGroup ? 'Group' : item.email ?? 'N/A';

    final Widget icon = isGroup
        ? const Icon(FluentIcons.group)
        : const Icon(FluentIcons.contact);

    final int count = isGroup
        ? item.userCount
        : (item.associatedDeviceIds?.length ?? 0);

    return Button(
      onPressed: () => _navigateToDetail(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Checkbox(
                checked: isSelected,
                onChanged: (value) => _onSelectionChanged(id, value),
              ),
            ),
            Expanded(flex: 2, child: icon),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(details, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Expanded(flex: 2, child: Text('$count')),
            const Expanded(flex: 2, child: Text('N/A')),
            const Expanded(flex: 2, child: Text('N/A')),
            const Expanded(flex: 3, child: Text('Default')),
          ],
        ),
      ),
    );
  }

  // --- Dialogs & Actions ---
  Future<void> _showAddUserDialog() async {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    String? selectedGroupId;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ContentDialog(
              title: const Text('Add New User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextBox(
                    controller: usernameController,
                    placeholder: 'Username',
                  ),
                  const SizedBox(height: 10),
                  TextBox(controller: emailController, placeholder: 'Email'),
                  const SizedBox(height: 10),
                  ComboBox<String?>(
                    placeholder: const Text('Select Group (optional)'),
                    value: selectedGroupId,
                    items: [
                      const ComboBoxItem(
                        value: 'unattached',
                        child: Text('Unattached Users'),
                      ),
                      ...allGroups.map((group) {
                        return ComboBoxItem(
                          value: group.groupId,
                          child: Text(group.groupName!),
                        );
                      }),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGroupId = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                Button(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  child: const Text('Add User'),
                  onPressed: () async {
                    if (!mounted) return;
                    final userData = {
                      'username': usernameController.text,
                      'email': emailController.text,
                      'groups': selectedGroupId == 'unattached'
                          ? []
                          : [selectedGroupId!],
                    };
                    try {
                      await apiService.createUser(userData);
                      if (!mounted) return;
                      Navigator.pop(context);
                      refreshData();
                    } catch (e) {
                      if (!mounted) return;
                      displayInfoBar(
                        context,
                        builder: (context, close) {
                          return InfoBar(
                            title: const Text('Error'),
                            content: Text('Failed to add user: $e'),
                            severity: InfoBarSeverity.error,
                            action: IconButton(
                              icon: const Icon(FluentIcons.clear),
                              onPressed: close,
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditUserDialog(User user) async {
    final usernameController = TextEditingController(text: user.username);
    final emailController = TextEditingController(text: user.email);
    String? selectedGroupId = user.groups?.isNotEmpty == true
        ? user.groups!.first
        : 'unattached'; // Use a special value for unattached

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ContentDialog(
              title: const Text('Edit User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextBox(
                    controller: usernameController,
                    placeholder: 'Username',
                  ),
                  const SizedBox(height: 10),
                  TextBox(controller: emailController, placeholder: 'Email'),
                  const SizedBox(height: 10),
                  ComboBox<String?>(
                    placeholder: const Text('Select Group'),
                    value: selectedGroupId,
                    items: [
                      const ComboBoxItem(
                        value: 'unattached',
                        child: Text('Unattached Users'),
                      ),
                      ...allGroups.map((group) {
                        return ComboBoxItem(
                          value: group.groupId,
                          child: Text(group.groupName!),
                        );
                      }),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGroupId = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                Button(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  child: const Text('Save'),
                  onPressed: () async {
                    if (!mounted) return;
                    final updatedData = {
                      'username': usernameController.text,
                      'email': emailController.text,
                      'groups': selectedGroupId == 'unattached'
                          ? []
                          : [selectedGroupId!],
                    };
                    try {
                      await apiService.updateUser(user.userId!, updatedData);
                      if (!mounted) return;
                      Navigator.pop(context);
                      refreshData();
                    } catch (e) {
                      if (!mounted) return;
                      displayInfoBar(
                        context,
                        builder: (context, close) {
                          return InfoBar(
                            title: const Text('Error'),
                            content: Text('Failed to update user: $e'),
                            severity: InfoBarSeverity.error,
                            action: IconButton(
                              icon: const Icon(FluentIcons.clear),
                              onPressed: close,
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showCreateGroupDialog() async {
    final groupNameController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text('Create New Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextBox(
                controller: groupNameController,
                placeholder: 'Group Name',
              ),
              const SizedBox(height: 10),
              TextBox(
                controller: descriptionController,
                placeholder: 'Description',
              ),
            ],
          ),
          actions: [
            Button(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              child: const Text('Create'),
              onPressed: () async {
                if (!mounted) return;
                final groupData = {
                  'group_name': groupNameController.text,
                  'description': descriptionController.text,
                };
                try {
                  await apiService.createGroup(groupData);
                  if (!mounted) return;
                  Navigator.pop(context);
                  refreshData();
                } catch (e) {
                  if (!mounted) return;
                  displayInfoBar(
                    context,
                    builder: (context, close) {
                      return InfoBar(
                        title: const Text('Error'),
                        content: Text('Failed to create group: $e'),
                        severity: InfoBarSeverity.error,
                        action: IconButton(
                          icon: const Icon(FluentIcons.clear),
                          onPressed: close,
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMoveUserDialog() async {
    String? selectedGroupId;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ContentDialog(
              title: const Text('Move Selected Users'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select a group to move the users to. Selecting "Unattached Users" will remove them from all groups.',
                  ),
                  const SizedBox(height: 10),
                  ComboBox<String?>(
                    placeholder: const Text('Select a Group'),
                    value: selectedGroupId,
                    items: [
                      const ComboBoxItem(
                        value: 'unattached',
                        child: Text('Unattached Users'),
                      ),
                      ...allGroups.map((group) {
                        return ComboBoxItem(
                          value: group.groupId,
                          child: Text(group.groupName!),
                        );
                      }),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGroupId = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                Button(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  child: const Text('Move'),
                  onPressed: selectedGroupId != null
                      ? () async {
                          if (!mounted) return;
                          try {
                            final List<String> groupList =
                                selectedGroupId == 'unattached'
                                ? []
                                : [selectedGroupId!];
                            for (String userId in _selectedIds) {
                              await apiService.updateUser(userId, {
                                'groups': groupList,
                              });
                            }
                            if (!mounted) return;
                            Navigator.pop(context);
                            refreshData();
                          } catch (e) {
                            if (!mounted) return;
                            displayInfoBar(
                              context,
                              builder: (context, close) {
                                return InfoBar(
                                  title: const Text('Error'),
                                  content: Text('Failed to move users: $e'),
                                  severity: InfoBarSeverity.error,
                                  action: IconButton(
                                    icon: const Icon(FluentIcons.clear),
                                    onPressed: close,
                                  ),
                                );
                              },
                            );
                          }
                        }
                      : null,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteDialog() async {
    final bool isUser = filteredList.any((item) {
      final String id;
      if (item is User) {
        id = item.userId!;
      } else if (item is GroupWithCount) {
        id = item.group.groupId!;
      } else {
        return false;
      }
      return _selectedIds.contains(id) && item is User;
    });

    final String type = isUser ? 'user(s)' : 'group(s)';

    await showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: Text('Delete $type?'),
          content: Text(
            'Are you sure you want to delete the selected $type? This action cannot be undone.',
          ),
          actions: [
            Button(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              child: const Text('Delete'),
              onPressed: () async {
                if (!mounted) return;
                try {
                  for (String id in _selectedIds) {
                    if (isUser) {
                      await apiService.deleteUser(id);
                    } else {
                      await apiService.deleteGroup(id);
                    }
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                  refreshData();
                } catch (e) {
                  if (!mounted) return;
                  displayInfoBar(
                    context,
                    builder: (context, close) {
                      return InfoBar(
                        title: const Text('Error'),
                        content: Text('Failed to delete $type: $e'),
                        severity: InfoBarSeverity.error,
                        action: IconButton(
                          icon: const Icon(FluentIcons.clear),
                          onPressed: close,
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void refreshData() {
    _selectedIds.clear();
    setState(() {
      usersAndGroupsFuture = fetchData();
    });
  }
}

// User and Group Detail Pages for nested navigation
class UserDetailPage extends StatefulWidget {
  final String userId;
  final ApiService apiService;
  final List<Group> allGroups;
  final VoidCallback onBack;
  final VoidCallback refreshData;

  const UserDetailPage({
    super.key,
    required this.userId,
    required this.apiService,
    required this.allGroups,
    required this.onBack,
    required this.refreshData,
  });

  @override
  UserDetailPageState createState() => UserDetailPageState();
}

class UserDetailPageState extends State<UserDetailPage> {
  late Future<User> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = widget.apiService.fetchUser(widget.userId);
  }

  // Added to refresh the data when returning from a nested view
  void _refreshAndGoBack() {
    widget.refreshData();
    widget.onBack();
  }

  Future<void> _showEditUserDialog(User user) async {
    final usernameController = TextEditingController(text: user.username);
    final emailController = TextEditingController(text: user.email);
    String? selectedGroupId = user.groups?.isNotEmpty == true
        ? user.groups!.first
        : 'unattached'; // Use a special value for unattached

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ContentDialog(
              title: const Text('Edit User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextBox(
                    controller: usernameController,
                    placeholder: 'Username',
                  ),
                  const SizedBox(height: 10),
                  TextBox(controller: emailController, placeholder: 'Email'),
                  const SizedBox(height: 10),
                  ComboBox<String?>(
                    placeholder: const Text('Select Group'),
                    value: selectedGroupId,
                    items: [
                      const ComboBoxItem(
                        value: 'unattached',
                        child: Text('Unattached Users'),
                      ),
                      ...widget.allGroups.map((group) {
                        return ComboBoxItem(
                          value: group.groupId,
                          child: Text(group.groupName!),
                        );
                      }),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGroupId = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                Button(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  child: const Text('Save'),
                  onPressed: () async {
                    if (!mounted) return;
                    final updatedData = {
                      'username': usernameController.text,
                      'email': emailController.text,
                      'groups': selectedGroupId == 'unattached'
                          ? []
                          : [selectedGroupId!],
                    };
                    try {
                      await widget.apiService.updateUser(
                        user.userId!,
                        updatedData,
                      );
                      if (!mounted) return;
                      Navigator.pop(context);
                      userFuture = widget.apiService.fetchUser(
                        user.userId!,
                      ); // Refresh the user data on the current page
                      setState(() {}); // Rebuild the page with new data
                      widget.refreshData(); // Refresh the main page list
                    } catch (e) {
                      if (!mounted) return;
                      displayInfoBar(
                        context,
                        builder: (context, close) {
                          return InfoBar(
                            title: const Text('Error'),
                            content: Text('Failed to update user: $e'),
                            severity: InfoBarSeverity.error,
                            action: IconButton(
                              icon: const Icon(FluentIcons.clear),
                              onPressed: close,
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: ProgressRing());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('User not found.'));
        } else {
          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommandBar(
                  primaryItems: [
                    CommandBarButton(
                      icon: const Icon(FluentIcons.edit),
                      label: const Text('Edit'),
                      onPressed: () => _showEditUserDialog(user),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  'Username: ${user.username ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Email: ${user.email ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Groups: ${user.groups?.join(', ') ?? 'None'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Number of Devices: ${user.associatedDeviceIds?.length ?? 0}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class GroupDetailPage extends StatefulWidget {
  final String groupId;
  final List<Group> allGroups;
  final ApiService apiService;
  final VoidCallback onBack;
  final VoidCallback refreshData;

  const GroupDetailPage({
    super.key,
    required this.groupId,
    required this.allGroups,
    required this.apiService,
    required this.onBack,
    required this.refreshData,
  });

  @override
  GroupDetailPageState createState() => GroupDetailPageState();
}

class GroupDetailPageState extends State<GroupDetailPage> {
  late Future<List<User>> usersFuture;
  List<User> _allUsersInGroup = [];
  List<User> filteredUsers = [];
  final TextEditingController searchController = TextEditingController();
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    usersFuture = fetchData();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<User>> fetchData() async {
    try {
      final users = await widget.apiService.fetchUsersByGroup(widget.groupId);
      if (mounted) {
        setState(() {
          _allUsersInGroup = users;
          filteredUsers = users;
          _selectedIds.clear(); // Clear selection on refresh
        });
      }
      return users;
    } catch (e) {
      if (mounted) {
        displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Error'),
              content: Text('Failed to load users: $e'),
              severity: InfoBarSeverity.error,
              action: IconButton(
                icon: const Icon(FluentIcons.clear),
                onPressed: close,
              ),
            );
          },
        );
      }
      rethrow;
    }
  }

  void onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = _allUsersInGroup.where((user) {
        return user.username!.toLowerCase().contains(query) ||
            user.email!.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _onSelectionChanged(String id, bool? checked) {
    setState(() {
      if (checked == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _showAddUserDialog() {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text('Add New User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextBox(controller: usernameController, placeholder: 'Username'),
              const SizedBox(height: 10),
              TextBox(controller: emailController, placeholder: 'Email'),
            ],
          ),
          actions: [
            Button(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              child: const Text('Add User to Group'),
              onPressed: () async {
                if (!mounted) return;
                final userData = {
                  'username': usernameController.text,
                  'email': emailController.text,
                  'groups': [widget.groupId],
                };
                try {
                  await widget.apiService.createUser(userData);
                  if (!mounted) return;
                  Navigator.pop(context);
                  fetchData(); // Refresh the user list in the group
                  widget.refreshData(); // Refresh the parent list
                } catch (e) {
                  if (!mounted) return;
                  displayInfoBar(
                    context,
                    builder: (context, close) {
                      return InfoBar(
                        title: const Text('Error'),
                        content: Text('Failed to add user: $e'),
                        severity: InfoBarSeverity.error,
                        action: IconButton(
                          icon: const Icon(FluentIcons.clear),
                          onPressed: close,
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text('Delete user(s)?'),
          content: const Text(
            'Are you sure you want to delete the selected user(s)? This action cannot be undone.',
          ),
          actions: [
            Button(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              child: const Text('Delete'),
              onPressed: () async {
                if (!mounted) return;
                try {
                  for (String id in _selectedIds) {
                    await widget.apiService.deleteUser(id);
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                  fetchData(); // Refresh the user list in the group
                  widget.refreshData(); // Refresh the parent list
                } catch (e) {
                  if (!mounted) return;
                  displayInfoBar(
                    context,
                    builder: (context, close) {
                      return InfoBar(
                        title: const Text('Error'),
                        content: Text('Failed to delete users: $e'),
                        severity: InfoBarSeverity.error,
                        action: IconButton(
                          icon: const Icon(FluentIcons.clear),
                          onPressed: close,
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMoveUserDialog() async {
    String? selectedGroupId;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ContentDialog(
              title: const Text('Move Selected Users'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select a group to move the users to. Selecting "Unattached Users" will remove them from all groups.',
                  ),
                  const SizedBox(height: 10),
                  ComboBox<String?>(
                    placeholder: const Text('Select a Group'),
                    value: selectedGroupId,
                    items: [
                      const ComboBoxItem(
                        value: 'unattached',
                        child: Text('Unattached Users'),
                      ),
                      ...widget.allGroups.map((group) {
                        return ComboBoxItem(
                          value: group.groupId,
                          child: Text(group.groupName!),
                        );
                      }),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGroupId = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                Button(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  child: const Text('Move'),
                  onPressed: selectedGroupId != null
                      ? () async {
                          if (!mounted) return;
                          try {
                            final List<String> groupList =
                                selectedGroupId == 'unattached'
                                ? []
                                : [selectedGroupId!];
                            for (String userId in _selectedIds) {
                              await widget.apiService.updateUser(userId, {
                                'groups': groupList,
                              });
                            }
                            if (!mounted) return;
                            Navigator.pop(context);
                            fetchData(); // Refresh the user list in the group
                            widget.refreshData(); // Refresh the parent list
                          } catch (e) {
                            if (!mounted) return;
                            displayInfoBar(
                              context,
                              builder: (context, close) {
                                return InfoBar(
                                  title: const Text('Error'),
                                  content: Text('Failed to move users: $e'),
                                  severity: InfoBarSeverity.error,
                                  action: IconButton(
                                    icon: const Icon(FluentIcons.clear),
                                    onPressed: close,
                                  ),
                                );
                              },
                            );
                          }
                        }
                      : null,
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar for users in group
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Text('Users in Group:'),
              const SizedBox(width: 10),
              Expanded(
                child: TextBox(
                  controller: searchController,
                  placeholder: 'Search users',
                  suffix: const Icon(FluentIcons.search),
                ),
              ),
            ],
          ),
        ),

        // Action bar for users in group
        CommandBar(
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('Add user'),
              onPressed: _showAddUserDialog,
            ),
            CommandBarButton(
              icon: const Icon(FluentIcons.folder_open),
              label: const Text('Move to group'),
              onPressed: _selectedIds.isNotEmpty ? _showMoveUserDialog : null,
            ),
            CommandBarButton(
              icon: const Icon(FluentIcons.delete),
              label: const Text('Delete'),
              onPressed: _selectedIds.isNotEmpty ? _showDeleteDialog : null,
            ),
          ],
        ),

        // Table header for users
        const Divider(size: 1),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Checkbox(checked: false, onChanged: null),
              ),
              Expanded(flex: 4, child: Text('Username')),
              Expanded(flex: 2, child: Text('Email')),
              Expanded(flex: 2, child: Text('Devices')),
              Expanded(flex: 3, child: Text('Security profile')),
            ],
          ),
        ),
        const Divider(size: 1),

        Expanded(
          child: FutureBuilder<List<User>>(
            future: usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: ProgressRing());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No users in this group.'));
              } else {
                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final isSelected = _selectedIds.contains(user.userId);
                    return Button(
                      onPressed: () {
                        // Navigate to UserDetailPage from here
                        final userGroupManagementPage = context
                            .findAncestorStateOfType<
                              _UserGroupManagementPageState
                            >();
                        if (userGroupManagementPage != null) {
                          userGroupManagementPage.setState(() {
                            userGroupManagementPage._selectedItemId =
                                user.userId;
                            userGroupManagementPage._selectedItem = user;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Checkbox(
                                checked: isSelected,
                                onChanged: (value) =>
                                    _onSelectionChanged(user.userId!, value),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(user.username ?? 'N/A'),
                            ),
                            Expanded(flex: 2, child: Text(user.email ?? 'N/A')),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${user.associatedDeviceIds?.length ?? 0}',
                              ),
                            ),
                            const Expanded(flex: 3, child: Text('Default')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
