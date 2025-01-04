import 'package:flutter/material.dart';
import 'package:shared/services/auth_service_interface.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
}

class AuthService extends ChangeNotifier implements AuthServiceInterface {
  AuthStatus _status = AuthStatus.unauthenticated;
  String _username = '';

  AuthStatus get status => _status;
  String get username => _username;

  @override
  Future<void> login(String username, String password) async {
    _status = AuthStatus.authenticating;
    debugPrint("ParkingApp: Authentication started...");
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    if (username.isEmpty || password.isEmpty) {
      debugPrint(
          "ParkingApp: Invalid credentials. Empty username or password.");
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      throw Exception(
          "Invalid credentials. Username and password are required.");
    }

    // Successful login
    _status = AuthStatus.authenticated;
    _username = username;
    debugPrint("ParkingApp: User $username successfully authenticated.");
    notifyListeners();
  }

  @override
  void logout() {
    debugPrint("ParkingApp: Logging out user $_username...");
    _status = AuthStatus.unauthenticated;
    _username = '';
    notifyListeners();
    debugPrint("ParkingApp: Logout successful.");
  }
}
