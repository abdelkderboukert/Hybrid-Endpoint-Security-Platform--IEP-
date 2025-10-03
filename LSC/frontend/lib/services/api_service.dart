// api/api_service.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart'; // Import your models file

import 'dart:typed_data'; // Required for byte data
// import 'package:file_picker/file_picker.dart';

import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'dart:io';

import 'package:file_picker/file_picker.dart';

class ApiService {
  final _storage = const FlutterSecureStorage();
  // IMPORTANT: Use your local IP address for physical device testing
  final _baseUrl = 'http://127.0.0.1:8000/api';

  static const bool isDevelopment = false;

<<<<<<< HEAD
=======
  List<dynamic> _filterDeletedItems(List<dynamic> items) {
  return items.where((item) {
    final isDeleted = item['is_deleted'] == 1 || item['is_deleted'] == true;
    return !isDeleted;
  }).toList();
}

>>>>>>> develop
  Future<bool> checkLicenseStatus() async {
    String? accessToken = await _storage.read(key: 'access_token');

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
        // return true;
        return data['is_active'] as bool? ?? false;
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

  // --- Admin Managment Methods ---

  Future<List<Admin>> fetchAdmins() async {
    String? accessToken = await _storage.read(key: 'access_token');
    final url = Uri.parse('$_baseUrl/network/admins');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
<<<<<<< HEAD
      return data.map((json) => Admin.fromJson(json)).toList();
=======
      final filteredData = _filterDeletedItems(data);
      return filteredData.map((json) => Admin.fromJson(json)).toList();
>>>>>>> develop
    } else {
      throw Exception('Failed to load groups: ${response.statusCode}');
    }
  }

  Future<Admin> createAdmin(Map<String, dynamic> adminData) async {
    String? accessToken = await _storage.read(key: 'access_token');

    // This calls your NEW AdminCreateViewSet
    final response = await http.post(
      Uri.parse('$_baseUrl/network/admins-create/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(adminData),
    );

    if (response.statusCode == 201) {
      // 201 Created
      return Admin.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create admin: ${response.body}');
    }
  }
  // --- New User and Group Management Methods ---

  // Fetch all groups
  Future<List<Group>> fetchGroups() async {
    String? accessToken = await _storage.read(key: 'access_token');
    final url = Uri.parse('$_baseUrl/network/groups/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
<<<<<<< HEAD
      return data.map((json) => Group.fromJson(json)).toList();
=======
      final filteredData = _filterDeletedItems(data);
      return filteredData.map((json) => Group.fromJson(json)).toList();
>>>>>>> develop
    } else {
      throw Exception('Failed to load groups: ${response.statusCode}');
    }
  }

  // Fetch users for a specific group
  Future<List<User>> fetchUsersByGroup(String groupId) async {
    String? accessToken = await _storage.read(key: 'access_token');
    final url = Uri.parse('$_baseUrl/network/users/?groups=$groupId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
<<<<<<< HEAD

      // Use .where() to filter the list
      return data
=======
      final filteredData = _filterDeletedItems(data);

      // Use .where() to filter the list
      return filteredData
>>>>>>> develop
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
    final url = Uri.parse('$_baseUrl/network/users/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
<<<<<<< HEAD
      final allUsers = data.map((json) => User.fromJson(json)).toList();
=======
      final filteredData = _filterDeletedItems(data);
      final allUsers = filteredData.map((json) => User.fromJson(json)).toList();
>>>>>>> develop
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

  // Future<void> generateAndDownloadInstaller({
  //   required String apiKey,
  //   required String ownerAdminId,
  // }) async {
  //   String? accessToken = await _storage.read(key: 'access_token');
  //   if (accessToken == null) {
  //     throw Exception("Access token not found. Please log in.");
  //   }

  //   // The endpoint of your Django class-based view
  //   final url = Uri.parse('$_baseUrl/generate-installer/');

  //   try {
  //     // 1. Send the POST request with the server's API key
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $accessToken',
  //       },
  //       body: jsonEncode({'api_key': apiKey, 'owner_admin_id': ownerAdminId}),
  //     );

  //     // 2. Check for a successful response (200 OK)
  //     if (response.statusCode == 200) {
  //       // 3. Get the filename from the 'Content-Disposition' header
  //       String? disposition = response.headers['content-disposition'];
  //       String outputFileName = 'Bluck-Security-Setup.exe'; // Default name
  //       if (disposition != null) {
  //         final match = RegExp(r'filename="([^"]+)"').firstMatch(disposition);
  //         if (match != null) {
  //           outputFileName = match.group(1)!;
  //         }
  //       }

  //       // 4. Get the file data as a list of bytes
  //       final Uint8List fileBytes = response.bodyBytes;

  //       // 5. Use file_picker to open a "Save As..." dialog
  //       String? outputFile = await FilePicker.platform.saveFile(
  //         dialogTitle: 'Please select an output file:',
  //         fileName: outputFileName,
  //         bytes: fileBytes,
  //       );

  //       if (outputFile == null) {
  //         // User canceled the picker
  //         throw Exception("File save was canceled.");
  //       }
  //     } else {
  //       // Handle API errors (e.g., 401 Unauthorized, 502 Bad Gateway)
  //       final errorBody = jsonDecode(response.body);
  //       throw Exception(errorBody['error'] ?? 'Failed to generate installer.');
  //     }
  //   } catch (e) {
  //     // Rethrow the exception to be handled by the UI
  //     rethrow;
  //   }
  // }

  Future<void> generateAndDownloadInstaller({
    required String apiKey,
    required String ownerAdminId,
  }) async {
    String? accessToken = await _storage.read(key: 'access_token');

    final url = Uri.parse('$_baseUrl/generate-installer/');

    try {
      debugPrint("1. Making HTTP request to $url...");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'api_key': apiKey, 'owner_admin_id': ownerAdminId}),
      );

      if (response.statusCode == 200) {
        final Uint8List fileBytes = response.bodyBytes;
        debugPrint(
          "2. Received response successfully. File size: ${fileBytes.length} bytes.",
        );

        if (fileBytes.isEmpty)
          throw Exception("Received empty file from server.");

        String? disposition = response.headers['content-disposition'];
        String outputFileName = 'Bluck-Security-Setup.exe';
        final match = RegExp(r'filename="([^"]+)"').firstMatch(disposition!);
        if (match != null) {
          outputFileName = match.group(1)!;
        }

        debugPrint("3. Showing 'Select Folder' dialog to user.");

        // --- THIS IS THE CORRECTED LOGIC ---
        // STEP 1: Get the directory path ONLY.
        String? outputDir = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Please select a folder to save the installer:',
        );

        // STEP 2: Manually create the full path by joining the directory and filename.
        final String outputPath = p.join(outputDir!, outputFileName);
        debugPrint("4. User selected path: $outputPath");

        try {
          debugPrint("5. Attempting to write file to disk...");
          // STEP 3: Manually create the File object and write the bytes.
          final File file = File(outputPath);
          await file.writeAsBytes(fileBytes);
          debugPrint("6. ✅ File write successful!");
        } catch (e) {
          debugPrint(
            "❌ CRITICAL ERROR: Failed to write file to disk. Error: $e",
          );
          throw Exception("Failed to save file to disk. Check permissions.");
        }
        // --- END OF CORRECTED LOGIC ---
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to generate installer.');
      }
    } catch (e) {
      debugPrint("❌ An error occurred in the process: $e");
      rethrow;
    }
  }
}
