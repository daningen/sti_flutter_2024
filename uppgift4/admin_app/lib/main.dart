// ignore_for_file: prefer_const_constructors

import 'package:admin_app/services/auth_service.dart';
import 'package:shared/bloc/auth/auth_bloc.dart';
import 'package:shared/bloc/auth/auth_state.dart';

import 'package:admin_app/views/login_view.dart';
import 'package:admin_app/views/nav_rail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'views/parking_space_view.dart';
import 'views/parking_view.dart';
import 'views/start_view.dart';
import 'views/statistics_view.dart';
import 'views/user_view.dart';
import 'views/vehicles_view.dart';

void main() {
  final authService = AuthService(); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: BlocProvider(
        create: (_) => AuthBloc(authService: authService),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/start',
    routes: [
      GoRoute(
        path: '/start',
        builder: (context, state) => const StartView(),
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const StatisticsView(),
      ),
      GoRoute(
        path: '/parkings',
        builder: (context, state) => const ParkingView(),
      ),
      GoRoute(
        path: '/parking-spaces',
        builder: (context, state) => const ParkingSpacesView(),
      ),
      GoRoute(
        path: '/vehicles',
        builder: (context, state) => const VehiclesView(),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UserView(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Managing App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 199, 16, 169),
        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: context.watch<ThemeNotifier>().themeMode,
      home: Scaffold(
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              // User is logged in
              return NavRailView(router: _router, initialIndex: 0);
            } else {
              return const LoginView();
            }
          },
        ),
      ),
    );
  }
}
