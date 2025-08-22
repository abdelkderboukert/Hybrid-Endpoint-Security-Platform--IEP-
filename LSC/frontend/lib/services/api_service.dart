// api/api_service.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart'; // Import your models file

class ApiService {
  final _storage = const FlutterSecureStorage();
  // IMPORTANT: Use your local IP address for physical device testing
  final _baseUrl = 'http://127.0.0.1:8000/api';

  static const bool isDevelopment = true;

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
        return data['is_active'] as bool? ?? false;
      } else if (response.statusCode == 403) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking license status: $e');
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

  // --- New method to register or update the server ---
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
      print('An error occurred during server registration: $e');
      rethrow;
    }
  }
}
