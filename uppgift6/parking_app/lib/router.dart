import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared/bloc/auth/auth_firebase_bloc.dart';

import 'package:parking_app/views/login_view.dart';
import 'package:parking_app/views/register_view.dart';
import 'package:parking_app/views/start_view.dart';
import 'package:parking_app/views/statistics_view.dart';
import 'package:parking_app/views/parking/parking_view.dart';
import 'package:parking_app/views/parking_space/parking_space_view.dart';
import 'package:parking_app/views/person/person_view.dart';
import 'package:parking_app/views/vehicle/vehicles_view.dart';

import 'package:parking_app/widgets/app_layout.dart';
import 'package:parking_app/utils/go_router_refresh_stream.dart';

/// **Create and return the GoRouter instance**
GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(
      context.read<AuthFirebaseBloc>().stream,
    ),
    redirect: (context, state) {
      final authState = context.read<AuthFirebaseBloc>().state;
      final isLoggedIn = authState is AuthAuthenticated;
      final hasCreatedPerson = authState is AuthFirebasePersonCreated;

      if (hasCreatedPerson) {
        return '/start';
      }

      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';

      debugPrint(
          'Redirect Logic: state=${state.uri.toString()}, isLoggedIn=$isLoggedIn, isLoggingIn=$isLoggingIn, isRegistering=$isRegistering');

      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      if (isLoggedIn && (isLoggingIn || isRegistering)) {
        return '/start';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/', // Root path
        builder: (context, state) => const AppLayout(
          child: StartView(),
        ),
      ),
      GoRoute(
        path: '/start',
        builder: (context, state) => const AppLayout(
          child: StartView(),
        ),
        routes: [
          GoRoute(
            path: 'statistics',
            builder: (context, state) => const AppLayout(
              child: StatisticsView(),
            ),
          ),
          GoRoute(
            path: 'parkings',
            builder: (context, state) => const ParkingView(),
          ),
          GoRoute(
            path: 'parking-spaces',
            builder: (context, state) => const AppLayout(
              child: ParkingSpacesView(),
            ),
          ),
          GoRoute(
              path: 'vehicles',
              builder: (context, state) => const VehiclesView()),
          GoRoute(
            path: 'persons',
            builder: (context, state) => const AppLayout(
              child: PersonView(),
            ),
          ),
        ],
      ),
    ],
  );
}
