import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthException implements Exception {}

class AuthService {
  final storage = const FlutterSecureStorage();
  final String _baseUrl = 'http://127.0.0.1:8000/api';

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }

  Future<dynamic> getAuthenticatedData(String endpoint) async {
    String? accessToken = await storage.read(key: 'access_token');
    if (accessToken == null) {
      throw AuthException(); // No token, so throw the exception
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 401) {
      throw AuthException(); // Token expired, throw the exception
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }

  Future<bool> refreshToken() async {
    String? refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null) {
      return false;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access_token', value: data['access']);
      return true;
    }

    // If refresh fails (e.g., refresh token is also expired),
    // it will return false. The calling UI should handle this
    // by logging out the user.
    return false;
  }

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access_token', value: data['access']);
      await storage.write(key: 'refresh_token', value: data['refresh']);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    String? accessToken = await storage.read(key: 'access_token');
    if (accessToken == null) {
      throw AuthException(); // No token, so throw the exception
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/logout/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 401) {
      throw AuthException(); // Token expired, throw the exception
    }

    if (response.statusCode == 200) {
      await storage.delete(key: 'access_token');
      await storage.delete(key: 'refresh_token');
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }
}
