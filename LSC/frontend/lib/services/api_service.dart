// api/api_service.dart

// import 'package:fluent_ui/fluent_ui.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final _storage = const FlutterSecureStorage();
  final _baseUrl = 'http://127.0.0.1/api';

  Future<bool> checkLicenseStatus() async {
    String? accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      return false;
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 403) {
      return false;
    } else {
      return false; // Other errors, including 401
    }
  }

  // Method to activate the license key
  Future<bool> activateLicense(String key) async {
    String? accessToken = await _storage.read(key: 'access_token');

    // Make sure we have a token to authenticate the request
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

      // Check the status code from the backend response
      if (response.statusCode == 200) {
        // Success: License key was valid and activated
        return true;
      } else {
        // The backend returned an error status code
        print('Activation failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      // Network or other unexpected errors
      print('An error occurred during license activation: $e');
      return false;
    }
  }
}
