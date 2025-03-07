// router.dart
import 'package:admin_app/utils/go_router_refresh_stream.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/bloc/auth/auth_firebase_bloc.dart';
import 'package:admin_app/views/login_view.dart';
import 'package:admin_app/views/nav_rail_view.dart';
import 'package:admin_app/views/register_view.dart';
import 'package:admin_app/views/parking/parking_view.dart';
import 'package:admin_app/views/parking_spaces/parking_space_view.dart';
import 'package:admin_app/views/person/person_view.dart';
import 'package:admin_app/views/statistics_view.dart';
import 'package:admin_app/views/vehicles/vehicles_view.dart';

GoRouter createRouter(BuildContext context) => GoRouter(
      initialLocation: '/login',
      refreshListenable: GoRouterRefreshStream(
        context.read<AuthFirebaseBloc>().stream,
      ),
      redirect: (context, state) {
        final authState = context.read<AuthFirebaseBloc>().state;
        final isLoggedIn = authState is AuthAuthenticated;
        final isRegistering = state.uri.toString() == '/register';
        final isPendingRegistration = authState is AuthUnauthenticated &&
            authState.errorMessage == 'Pending person creation';

        debugPrint(
            'Redirect Logic: state=${state.uri.toString()}, isLoggedIn=$isLoggedIn, isRegistering=$isRegistering, isPendingRegistration=$isPendingRegistration');

        if (isPendingRegistration) {
          return '/register';
        }

        if (!isLoggedIn && !isRegistering) {
          return '/login';
        }

        if (isLoggedIn) {
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
          path: '/start',
          builder: (context, state) => const NavRailView(initialIndex: 0),
          routes: [
            // Sub-routes for the main app
            GoRoute(
              path: 'statistics',
              builder: (context, state) => const StatisticsView(),
            ),
            GoRoute(
              path: 'parkings',
              builder: (context, state) => const ParkingView(),
            ),
            GoRoute(
              path: 'parking-spaces',
              builder: (context, state) => const ParkingSpacesView(),
            ),
            GoRoute(
              path: 'vehicles',
              builder: (context, state) => const VehiclesView(),
            ),
            GoRoute(
              path: 'persons',
              builder: (context, state) => const PersonView(),
            ),
          ],
        ),
      ],
    );
