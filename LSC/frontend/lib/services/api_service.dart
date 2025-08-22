// api/api_service.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart'; // Import your models file

class ApiService {
  final _storage = const FlutterSecureStorage();
  final _baseUrl = 'http://127.0.0.1:8000/api';

  Future<bool> checkLicenseStatus() async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      return false;
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
        // Assuming your backend sends a boolean field like 'is_active'
        return data['is_active'] as bool? ?? false;
      } else if (response.statusCode == 403) {
        // Forbidden, license likely not active
        return false;
      } else {
        // Other errors, including 401 Unauthorized
        return false;
      }
    } catch (e) {
      // Network or other exceptions
      print('Error checking license status: $e');
      return false;
    }
  }

  // New method to fetch and return the Admin object
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
        // Decode the JSON response
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        // Use the Admin.fromJson() factory to create an Admin object
        return Admin.fromJson(jsonData);
      } else {
        // Log a more informative error message
        print(
          'Failed to fetch admin profile with status code: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('An error occurred while fetching admin profile: $e');
      return null;
    }
  }

  // The activateLicense method remains the same and is correct as is.
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
        print('Activation failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('An error occurred during license activation: $e');
      return false;
    }
  }
}
