import 'package:flutter/material.dart';
import 'package:parking_app/views/register_view.dart';
import 'package:parking_app/views/start_view.dart';
import 'package:parking_app/views/user_page.dart';
import 'package:parking_app/views/vehicles_page.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/auth_service.dart';
import 'package:parking_app/views/login_view.dart';
import 'package:go_router/go_router.dart';
import 'views/home_page.dart';
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
      debugShowCheckedModeBanner: false,
    );
  }

  final GoRouter _router = GoRouter(
    // initialLocation: '/login', // Start with the login page
    initialLocation: '/start',
    routes: [
      GoRoute(
        path: '/start',
        builder: (context, state) => const StartView(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/my-vehicles',
        builder: (context, state) => const VehiclesView(),
      ),
      GoRoute(
        path: '/parking',
        builder: (context, state) => const ParkingView(),
      ),
      GoRoute(
        path: '/parking-spaces',
        builder: (context, state) => const ParkingSpacesView(),
      ),
      GoRoute(
        path: '/user-page',
        builder: (context, state) => const UserView(),
      ),
    ],
  );

  ParkingApp({super.key});
}
