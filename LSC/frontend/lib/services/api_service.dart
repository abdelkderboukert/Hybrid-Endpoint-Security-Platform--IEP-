// // api/api_service.dart

// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import '../models/models.dart'; // Import your models file

// class ApiService {
//   final _storage = const FlutterSecureStorage();
//   // IMPORTANT: Use your local IP address for physical device testing
//   final _baseUrl = 'http://127.0.0.1:8000/api';

//   static const bool isDevelopment = false;

//   Future<bool> checkLicenseStatus() async {
//     String? accessToken = await _storage.read(key: 'access_token');
//     if (accessToken == null) {
//       return false;
//     }

//     if (isDevelopment) {
//       // Return true to pass the license check
//       return true;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/profile/'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $accessToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         return true;
//         // return data['is_active'] as bool? ?? false;
//       } else if (response.statusCode == 403) {
//         return false;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       print('Error checking license status: $e');
//       return false;
//     }
//   }

//   Future<Admin?> getAdminProfile() async {
//     String? accessToken = await _storage.read(key: 'access_token');
//     if (accessToken == null) {
//       return null;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/profile/'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $accessToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonData = jsonDecode(response.body);
//         return Admin.fromJson(jsonData);
//       } else {
//         print(
//           'Failed to fetch admin profile with status code: ${response.statusCode}',
//         );
//         return null;
//       }
//     } catch (e) {
//       print('An error occurred while fetching admin profile: $e');
//       return null;
//     }
//   }

//   Future<bool> activateLicense(String key) async {
//     String? accessToken = await _storage.read(key: 'access_token');
//     if (accessToken == null) {
//       return false;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/license/activate/'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $accessToken',
//         },
//         body: jsonEncode({'key': key}),
//       );

//       if (response.statusCode == 200) {
//         return true;
//       } else {
//         print('Activation failed with status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       print('An error occurred during license activation: $e');
//       return false;
//     }
//   }

//   Future<Map<String, dynamic>> registerServer() async {
//     String? accessToken = await _storage.read(key: 'access_token');
//     if (accessToken == null) {
//       throw Exception("Access token not found. Please log in.");
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/server/detect/'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $accessToken',
//         },
//       );

//       final responseBody = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return {
//           'success': true,
//           'message': responseBody['message'],
//           'server_data': responseBody['server'],
//         };
//       } else {
//         throw Exception(responseBody['error'] ?? 'An unknown error occurred.');
//       }
//     } catch (e) {
//       print('An error occurred during server registration: $e');
//       rethrow;
//     }
//   }

//   // --- New User and Group Management Methods ---

//   // Fetch all groups
//   Future<List<Group>> fetchGroups() async {
//     String? accessToken = await _storage.read(key: 'access_token');
//     if (accessToken == null) {
//       throw Exception("Access token not found.");
//     }
//     final url = Uri.parse('$_baseUrl/network/groups/');
//     final response = await http.get(
//       url,
//       headers: {'Authorization': 'Bearer $accessToken'},
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((json) => Group.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load groups: ${response.statusCode}');
//     }
//   }

//   // Fetch users for a specific group
//   Future<List<User>> fetchUsersByGroup(String groupId) async {
//     String? accessToken = await _storage.read(key: 'access_token');
//     if (accessToken == null) {
//       throw Exception("Access token not found.");
//     }
//     final url = Uri.parse('$_baseUrl/network/users/?groups=$groupId');
//     final response = await http.get(
//       url,
//       headers: {'Authorization': 'Bearer $accessToken'},
//     );
//     // if (response.statusCode == 200) {
//     //   final List<dynamic> data = json.decode(response.body);
//     //   print(data);
//     //   return data.map((json) => User.fromJson(json)).toList();
//     // }
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       print(data); // For debugging

//       // Use .where() to filter the list
//       return data
//           .where((userJson) {
//             final groups = userJson['groups'];
//             // Check if 'groups' is a List and if it contains the groupId
//             return groups is List && groups.contains(groupId);
//           })
//           .map(
//             (userJson) => User.fromJson(userJson),
//           ) // Map the filtered list to User objects
//           .toList();
//     } else {
//       throw Exception('Failed to load users for group: ${response.statusCode}');
//     }
//   }

//   // Fetch users that are not in any group
//   Future<List<User>> fetchUnattachedUsers() async {
//     String? accessToken = await _storage.read(key: 'access_token');
//     if (accessToken == null) {
//       throw Exception("Access token not found.");
//     }
//     final url = Uri.parse('$_baseUrl/network/users/');
//     final response = await http.get(
//       url,
//       headers: {'Authorization': 'Bearer $accessToken'},
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       final allUsers = data.map((json) => User.fromJson(json)).toList();
//       // Filter for users where the 'groups' list is empty or null
//       return allUsers
//           .where((user) => user.groups == null || user.groups!.isEmpty)
//           .toList();
//     } else {
//       throw Exception('Failed to load users: ${response.statusCode}');
//     }
//   }

//   // ADDED: Fetch a single user by ID
//   Future<User> fetchUser(String userId) async {
//     String? accessToken = await _storage.read(key: 'access_token');
//     if (accessToken == null) {
//       throw Exception("Access token not found.");
//     }
//     final url = Uri.parse('$_baseUrl/network/users/$userId/');
//     final response = await http.get(
//       url,
//       headers: {'Authorization': 'Bearer $accessToken'},
//     );
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       return User.fromJson(data);
//     } else {
//       throw Exception('Failed to load user: ${response.statusCode}');
//     }
//   }

//   // Create a new group
//   Future<Group> createGroup(Map<String, dynamic> groupData) async {
//     String? accessToken = await _storage.read(key: 'access_token');
//     if (accessToken == null) {
//       throw Exception("Access token not found.");
//     }
//     final response = await http.post(
//       Uri.parse('$_baseUrl/network/groups/'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $accessToken',
//       },
//       body: jsonEncode(groupData),
//     );
//     if (response.statusCode == 201) {
//       return Group.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to create group: ${response.body}');
//     }
//   }

//   // Edit an existing group
//   Future<Group> updateGroup(
//     String groupId,
//     Map<String, dynamic> groupData,
//   ) async {
//     String? accessToken = await _storage.read(key: 'access_token');
//     if (accessToken == null) {
//       throw Exception("Access token not found.");
//     }
//     final response = await http.patch(
//       Uri.parse('$_baseUrl/network/groups/$groupId/'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $accessToken',
//       },
//       body: jsonEncode(groupData),
//     );
//     if (response.statusCode == 200) {
//       return Group.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to update group: ${response.body}');
//     }
//   }

//   // Delete a group
//   Future<void> deleteGroup(String groupId) async {
//     String? accessToken = await _storage.read(key: 'access_token');
//     if (accessToken == null) {
//       throw Exception("Access token not found.");
//     }
//     final response = await http.delete(
//       Uri.parse('$_baseUrl/network/groups/$groupId/'),
//       headers: {'Authorization': 'Bearer $accessToken'},
//     );
//     if (response.statusCode != 204) {
//       throw Exception('Failed to delete group: ${response.statusCode}');
//     }
//   }

//   // Create a new user
//   Future<User> createUser(Map<String, dynamic> userData) async {
//     String? accessToken = await _storage.read(key: 'access_token');
//     if (accessToken == null) {
//       throw Exception("Access token not found.");
//     }
//     final response = await http.post(
//       Uri.parse('$_baseUrl/network/users-create/'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $accessToken',
//       },
//       body: jsonEncode(userData),
//     );
//     if (response.statusCode == 201) {
//       return User.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to create user: ${response.body}');
//     }
//   }

//   // Update an existing user
//   Future<User> updateUser(String userId, Map<String, dynamic> userData) async {
//     String? accessToken = await _storage.read(key: 'access_token');
//     if (accessToken == null) {
//       throw Exception("Access token not found.");
//     }
//     final response = await http.patch(
//       Uri.parse('$_baseUrl/network/users/$userId/'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $accessToken',
//       },
//       body: jsonEncode(userData),
//     );
//     if (response.statusCode == 200) {
//       return User.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to update user: ${response.body}');
//     }
//   }

//   // Delete a user
//   Future<void> deleteUser(String userId) async {
//     String? accessToken = await _storage.read(key: 'access_token');
//     if (accessToken == null) {
//       throw Exception("Access token not found.");
//     }
//     final response = await http.delete(
//       Uri.parse('$_baseUrl/network/users/$userId/'),
//       headers: {'Authorization': 'Bearer $accessToken'},
//     );
//     if (response.statusCode != 204) {
//       throw Exception('Failed to delete user: ${response.statusCode}');
//     }
//   }

//   // Move a user from one group to another
//   Future<User> moveUserToGroup(String userId, String? newGroupId) async {
//     String? accessToken = await _storage.read(key: 'access_token');
//     if (accessToken == null) {
//       throw Exception("Access token not found.");
//     }
//     final List<String> groupList = newGroupId != null ? [newGroupId] : [];

//     final response = await http.patch(
//       Uri.parse('$_baseUrl/network/users/$userId/'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $accessToken',
//       },
//       body: jsonEncode({'groups': groupList}),
//     );

//     if (response.statusCode == 200) {
//       return User.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to move user: ${response.body}');
//     }
//   }

//   Future<List<ServerNode>> fetchNetworkHierarchy() async {
//     // ✅ This is correct
//     String? accessToken = await _storage.read(key: 'access_token');
//     if (accessToken == null) {
//       throw Exception("Access token not found.");
//     }

//     // Corrected URL
//     final response = await http.get(
//       Uri.parse('$_baseUrl/servers/hierarchy/'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $accessToken',
//       },
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> jsonResponse = jsonDecode(response.body);
//       // This will now correctly use ServerNode from models.dart
//       print(response.body);
//       return jsonResponse
//           .map((serverJson) => ServerNode.fromJson(serverJson))
//           .toList();
//     } else {
//       throw Exception('Failed to load network data: ${response.statusCode}');
//     }
//   }
// }

// api/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart'; // Import your models file

class ApiService {
  final _storage = const FlutterSecureStorage();
  // IMPORTANT: Use your local IP address for physical device testing
  final _baseUrl = 'http://127.0.0.1:8000/api';
  // --- Updated: Build service URL (Python build service) ---
  final _buildServiceUrl = 'http://127.0.0.1:5000'; // Python build service
  // ---

  static const bool isDevelopment = false;

  Future<bool> checkLicenseStatus() async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      return false;
    }

    if (isDevelopment) {
      // Return true to pass the license check
      return true;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return true;
        // return data['is_active'] as bool? ?? false;
      } else if (response.statusCode == 403) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Admin?> getAdminProfile() async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return Admin.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> activateLicense(String key) async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/license/activate/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'key': key}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> registerServer() async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      throw Exception("Access token not found. Please log in.");
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/server/detect/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseBody['message'],
          'server_data': responseBody['server'],
        };
      } else {
        throw Exception(responseBody['error'] ?? 'An unknown error occurred.');
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- New User and Group Management Methods ---

  // Fetch all groups
  Future<List<Group>> fetchGroups() async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      throw Exception("Access token not found.");
    }
    final url = Uri.parse('$_baseUrl/network/groups/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Group.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load groups: ${response.statusCode}');
    }
  }

  // Fetch users for a specific group
  Future<List<User>> fetchUsersByGroup(String groupId) async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      throw Exception("Access token not found.");
    }
    final url = Uri.parse('$_baseUrl/network/users/?groups=$groupId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // Use .where() to filter the list
      return data
          .where((userJson) {
            final groups = userJson['groups'];
            // Check if 'groups' is a List and if it contains the groupId
            return groups is List && groups.contains(groupId);
          })
          .map(
            (userJson) => User.fromJson(userJson),
          ) // Map the filtered list to User objects
          .toList();
    } else {
      throw Exception('Failed to load users for group: ${response.statusCode}');
    }
  }

  // Fetch users that are not in any group
  Future<List<User>> fetchUnattachedUsers() async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      throw Exception("Access token not found.");
    }
    final url = Uri.parse('$_baseUrl/network/users/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final allUsers = data.map((json) => User.fromJson(json)).toList();
      // Filter for users where the 'groups' list is empty or null
      return allUsers
          .where((user) => user.groups == null || user.groups!.isEmpty)
          .toList();
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  // ADDED: Fetch a single user by ID
  Future<User> fetchUser(String userId) async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      throw Exception("Access token not found.");
    }
    final url = Uri.parse('$_baseUrl/network/users/$userId/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  }

  // Create a new group
  Future<Group> createGroup(Map<String, dynamic> groupData) async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      throw Exception("Access token not found.");
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/network/groups/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(groupData),
    );
    if (response.statusCode == 201) {
      return Group.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create group: ${response.body}');
    }
  }

  // Edit an existing group
  Future<Group> updateGroup(
    String groupId,
    Map<String, dynamic> groupData,
  ) async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      throw Exception("Access token not found.");
    }
    final response = await http.patch(
      Uri.parse('$_baseUrl/network/groups/$groupId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(groupData),
    );
    if (response.statusCode == 200) {
      return Group.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update group: ${response.body}');
    }
  }

  // Delete a group
  Future<void> deleteGroup(String groupId) async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      throw Exception("Access token not found.");
    }
    final response = await http.delete(
      Uri.parse('$_baseUrl/network/groups/$groupId/'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete group: ${response.statusCode}');
    }
  }

  // Create a new user
  Future<User> createUser(Map<String, dynamic> userData) async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      throw Exception("Access token not found.");
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/network/users-create/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(userData),
    );
    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  // Update an existing user
  Future<User> updateUser(String userId, Map<String, dynamic> userData) async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      throw Exception("Access token not found.");
    }
    final response = await http.patch(
      Uri.parse('$_baseUrl/network/users/$userId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(userData),
    );
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  // Delete a user
  Future<void> deleteUser(String userId) async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      throw Exception("Access token not found.");
    }
    final response = await http.delete(
      Uri.parse('$_baseUrl/network/users/$userId/'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete user: ${response.statusCode}');
    }
  }

  // Move a user from one group to another
  Future<User> moveUserToGroup(String userId, String? newGroupId) async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      throw Exception("Access token not found.");
    }
    final List<String> groupList = newGroupId != null ? [newGroupId] : [];

    final response = await http.patch(
      Uri.parse('$_baseUrl/network/users/$userId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'groups': groupList}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to move user: ${response.body}');
    }
  }

  Future<List<ServerNode>> fetchNetworkHierarchy() async {
    // ✅ This is correct
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      throw Exception("Access token not found.");
    }

    // Corrected URL
    final response = await http.get(
      Uri.parse('$_baseUrl/servers/hierarchy/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      // This will now correctly use ServerNode from models.dart
      return jsonResponse
          .map((serverJson) => ServerNode.fromJson(serverJson))
          .toList();
    } else {
      throw Exception('Failed to load network data: ${response.statusCode}');
    }
  }

  // --- Updated Build Service Methods for Python Build Service ---

  /// Start build process with the Python build service
  Future<BuildStartResponse> startBuild({
    required String parentServerId,
    required String parentServerIp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_buildServiceUrl/build'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'PARENT_SERVER_ID': parentServerId,
          'PARENT_SERVER_IP': parentServerIp,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 202) {
        return BuildStartResponse(
          buildId: responseBody['build_id'],
          status: responseBody['status'],
          message: responseBody['message'],
        );
      } else {
        throw Exception(responseBody['error'] ?? 'Failed to start build');
      }
    } catch (e) {
      throw Exception('Network error or server unreachable: $e');
    }
  }

  /// Get build status
  Future<BuildStatusResponse> getBuildStatus(String buildId) async {
    try {
      final response = await http.get(
        Uri.parse('$_buildServiceUrl/build/$buildId/status'),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return BuildStatusResponse(
          status: responseBody['status'],
          progress: responseBody['progress'],
          message: responseBody['message'],
          timestamp: responseBody['timestamp'],
          downloaded: responseBody['downloaded'] ?? false,
        );
      } else {
        throw Exception(responseBody['error'] ?? 'Failed to get build status');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Download build installer
  Future<void> downloadBuild(String buildId, String filePath) async {
    try {
      final response = await http.get(
        Uri.parse('$_buildServiceUrl/build/$buildId/download'),
      );

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(responseBody['error'] ?? 'Failed to download build');
      }
    } catch (e) {
      throw Exception('Download error: $e');
    }
  }

  /// Launch download URL directly (alternative method)
  Future<void> launchBuildDownload(String buildId) async {
    final downloadUrl = '$_buildServiceUrl/build/$buildId/download';
    final uri = Uri.parse(downloadUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch download URL');
    }
  }

  /// Get health status of build service
  Future<Map<String, dynamic>> getBuildServiceHealth() async {
    try {
      final response = await http.get(Uri.parse('$_buildServiceUrl/health'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Build service unhealthy');
      }
    } catch (e) {
      throw Exception('Build service unreachable: $e');
    }
  }
}

// --- Build Service Data Models ---

class BuildStartResponse {
  final String buildId;
  final String status;
  final String message;

  BuildStartResponse({
    required this.buildId,
    required this.status,
    required this.message,
  });
}

class BuildStatusResponse {
  final String status;
  final int progress;
  final String message;
  final String timestamp;
  final bool downloaded;

  BuildStatusResponse({
    required this.status,
    required this.progress,
    required this.message,
    required this.timestamp,
    required this.downloaded,
  });
}
