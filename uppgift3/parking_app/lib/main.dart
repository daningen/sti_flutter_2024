import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_app/views/user_page.dart';
import 'views/start_page.dart';
import 'views/vehicles_page.dart';
import 'views/parking_page.dart';
import 'views/parking_spaces_page.dart';
// import 'views/user_page.dart';

void main() {
  runApp(ParkingApp());
}

class ParkingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const StartPage(),
      ),
      GoRoute(
        path: '/my-vehicles',
        builder: (context, state) => const VehiclesPage(),
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
      // Add other routes for your app
    ],
  );

  ParkingApp({super.key});
}
