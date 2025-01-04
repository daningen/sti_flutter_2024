import 'package:flutter/material.dart';
import 'package:shared/services/auth_service_interface.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated }

class AuthService implements AuthServiceInterface {
  AuthStatus _status = AuthStatus.unauthenticated;
  String _username = '';

  AuthStatus get status => _status;
  String get username => _username;

  @override
  Future<void> login(String username, String password) async {
    _status = AuthStatus.authenticating;
    debugPrint("[AuthService] Authentication process started...");

    try {
      // Simulate delay (e.g., API call)
      await Future.delayed(const Duration(seconds: 2));

      if (username != "admin" || password != "password") {
        debugPrint(
            "[AuthService] Invalid credentials provided: username=$username");
        _status = AuthStatus.unauthenticated;
        throw Exception('Invalid credentials for admin_app');
      }

      // Successfully authenticated
      _status = AuthStatus.authenticated;
      _username = username;
      debugPrint("[AuthService] Authentication successful for user $username.");
    } catch (e) {
      debugPrint("[AuthService] Authentication failed: ${e.toString()}");
      rethrow; // Propagate the error for further handling
    }
  }

  @override
  void logout() {
    debugPrint("[AuthService] Logging out user $_username...");
    _status = AuthStatus.unauthenticated;
    _username = '';
    debugPrint("[AuthService] Logout successful.");
  }
}
