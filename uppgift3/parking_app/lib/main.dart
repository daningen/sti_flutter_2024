import 'package:flutter/material.dart';
import 'package:parking_app/views/user_page.dart';
import 'package:parking_app/views/vehicles_page.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/auth_service.dart';
import 'package:parking_app/views/login_view.dart';
import 'package:go_router/go_router.dart';
import 'views/start_page.dart';
import 'views/parking_page.dart';
import 'views/parking_spaces_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: ParkingApp(),
    ),
  );
}

class ParkingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }

  final GoRouter _router = GoRouter(
    initialLocation: '/login', // Start with the login page
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const StartPage(),
      ),
      GoRoute(
        path: '/my-vehicles',
        builder: (context, state) => const VehiclesView(),
      ),
      GoRoute(
        path: '/parking',
        builder: (context, state) => const ParkingPage(),
      ),
      GoRoute(
        path: '/parking-spaces',
        builder: (context, state) => const ParkingSpacesPage(),
      ),
      GoRoute(
        path: '/user-page',
        builder: (context, state) => const UserPage(),
      ),
    ],
  );

  ParkingApp({super.key});
}
