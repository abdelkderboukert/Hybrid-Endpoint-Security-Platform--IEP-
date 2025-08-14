import 'package:crypto/crypto.dart'; // Add crypto: ^3.0.3 to pubspec.yaml
import 'dart:convert'; // for utf8.encode
import 'package:flutter/foundation.dart';
import 'package:resilient_sync_app/database/isar_service.dart';
import 'package:resilient_sync_app/database/models/admin.dart';
import 'package:isar/isar.dart';

class AuthService {
  final IsarService _isarService = IsarService.instance;

  // Notifier to hold the currently logged-in admin's state
  final ValueNotifier<Admin?> currentAdmin = ValueNotifier(null);

  /// Hashes the password using SHA-256.
  /// NOTE: For production, this MUST match the hashing algorithm used by your Django backend (e.g., PBKDF2).
  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // data being hashed
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Attempts to log in an admin using their username and password.
  Future<bool> login(String username, String password) async {
    final isar = await _isarService.getDb();
    
    // 1. Find the admin by username in the local database
    final admin = await isar.admins.where().usernameEqualTo(username).findFirst();

    if (admin == null) {
      print("Login Failed: Admin '$username' not found locally.");
      return false;
    }

    // 2. Hash the provided password and compare it with the stored hash
    final hashedPassword = _hashPassword(password);
    
    if (hashedPassword == admin.passwordHash) {
      print("Login Successful: Welcome ${admin.username}");
      currentAdmin.value = admin; // Set the current admin
      return true;
    } else {
      print("Login Failed: Incorrect password for admin '$username'.");
      currentAdmin.value = null;
      return false;
    }
  }

  void logout() {
    currentAdmin.value = null;
    print("Admin logged out.");
  }
}