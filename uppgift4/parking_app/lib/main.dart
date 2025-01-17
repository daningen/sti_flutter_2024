import 'package:flutter/material.dart';
import 'package:parking_app/services/auth_service.dart';
import 'package:parking_app/views/register_view.dart';
import 'package:parking_app/views/start_view.dart';
import 'package:parking_app/views/user_view.dart';
import 'package:parking_app/views/vehicle/vehicles_view.dart';
import 'package:provider/provider.dart';

import 'package:parking_app/views/login_view.dart';
import 'package:parking_app/providers/theme_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/bloc/auth/auth_bloc.dart';
import 'views/home_page.dart';
import 'views/parking_view.dart';
import 'views/parking_spaces_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthBloc>(
          create: (_) => AuthBloc(authService: AuthService()),
        ),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: ParkingApp(),
    ),
  );
}

class ParkingApp extends StatelessWidget {
  ParkingApp({super.key});

  final GoRouter _router = GoRouter(
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp.router(
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.lightBlue,
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.lightGreen,
              backgroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedItemColor: Colors.amber,
              unselectedItemColor: Color.fromARGB(255, 245, 210, 210),
            ),
          ),
          themeMode: themeNotifier.themeMode,
        );
      },
    );
  }
}
