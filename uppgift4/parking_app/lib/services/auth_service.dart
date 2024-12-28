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

  Future<String?> login(String username, String password) async {
    await Future.delayed(
        const Duration(seconds: 2)); // Simulerar nätverksfördröjning

    if (username == "admin" && password == "password") {
      return null; // Lyckad inloggning: Returnerar null
    } else {
      return "Ogiltiga inloggningsuppgifter."; // Misslyckad inloggning: Returnerar felmeddelande
    }
  }

  void logout() {
    _status = AuthStatus.unauthenticated;
    _username = '';
    notifyListeners();
  }
}
