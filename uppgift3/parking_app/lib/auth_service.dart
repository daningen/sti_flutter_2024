import 'package:flutter/material.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
}

class AuthService extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unauthenticated;
  AuthStatus get status => _status;

  Future<void> login() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  void logout() {
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
