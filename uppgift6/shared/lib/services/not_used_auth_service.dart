// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';

// enum AppMode {
//   admin,
//   parking,
// }

// enum AuthStatus {
//   unauthenticated,
//   authenticating,
//   authenticated,
// }

// class AuthService extends ChangeNotifier {
//   final AppMode appMode;

//   AuthService({required this.appMode});

//   AuthStatus _status = AuthStatus.unauthenticated;
//   AuthStatus get status => _status;

//   String _username = '';
//   String get username => _username;

//   Future<String?> login(String username, String password) async {
//     _status = AuthStatus.authenticating;
//     notifyListeners();

//     try {
//       debugPrint("Login started for appMode: $appMode");

//       await Future.delayed(const Duration(seconds: 2));

//       if (appMode == AppMode.admin) {
//         debugPrint("Admin mode detected");
//         if (username != "admin" || password != "password") {
//           debugPrint(
//               "Invalid admin credentials: username=$username, password=$password");
//           throw Exception('Invalid credentials for admin_app');
//         }
//       } else if (appMode == AppMode.parking) {
//         debugPrint("Parking mode detected");
//         if (username.isEmpty || password.isEmpty) {
//           throw Exception('Username and password are required for parking_app');
//         }
//       }

//       _status = AuthStatus.authenticated;
//       _username = username;
//       debugPrint("Authentication successful for $username");
//       notifyListeners();
//       return null;
//     } catch (e) {
//       _status = AuthStatus.unauthenticated;
//       debugPrint("Authentication failed: ${e.toString()}");
//       notifyListeners();
//       return e.toString();
//     }
//   }

//   void logout() {
//     _status = AuthStatus.unauthenticated;
//     _username = '';
//     notifyListeners();
//   }
// }
