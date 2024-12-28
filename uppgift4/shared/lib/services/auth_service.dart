// auth_service.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// ignore: unused_import
import 'package:shared/services/auth_service.dart';

class AuthService {
  AuthService();

  String _username = '';
  String get username => _username;

  /// Simulates the login process and validates the provided credentials.
  Future<void> login(String username, String password) async {
    debugPrint("Login started");

    // Simulate API call/authentication
    await Future.delayed(const Duration(seconds: 2));

    // Simulate password check (replace with your actual logic)
    if (username != "admin" || password != "password") {
      throw Exception(
          'Invalid credentials'); // Throw exception for invalid credentials
    }

    _username = username; // Save the username for authenticated state
  }

  /// Simulates the logout process by clearing user data.
  void logout() {
    _username = '';
    debugPrint("User logged out");
    // Add additional logout logic if needed (e.g., clearing tokens, session)
  }
}
