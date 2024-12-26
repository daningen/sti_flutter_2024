// auth_service.dart
import 'package:flutter/material.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
}

class AuthService extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unauthenticated;
  AuthStatus get status => _status;

  String _username = '';
  String get username => _username;

  Future<void> login(String username, String password) async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      // Simulate password check
      if (password.isEmpty) throw Exception('Invalid credentials');
      _status = AuthStatus.authenticated;
      _username = username;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  void logout() {
    _status = AuthStatus.unauthenticated;
    _username = '';
    notifyListeners();
  }
}
