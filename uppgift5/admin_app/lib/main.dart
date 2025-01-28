// ignore_for_file: duplicate_import

import 'package:admin_app/utils/go_router_refresh_stream.dart';
import 'package:admin_app/views/parking/parking_view.dart';
import 'package:admin_app/views/parking_spaces/parking_space_view.dart';
import 'package:admin_app/views/person/person_view.dart';
import 'package:admin_app/views/register_view.dart';
import 'package:admin_app/views/statistics_view.dart';
import 'package:admin_app/views/vehicles/vehicles_view.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:admin_app/firebase_options.dart';
import 'package:admin_app/bloc/auth/auth_firebase_bloc.dart';
import 'package:admin_app/theme_notifier.dart';
import 'package:admin_app/views/login_view.dart';
import 'package:admin_app/views/nav_rail_view.dart';
import 'package:shared/bloc/person/person_bloc.dart';
import 'package:shared/bloc/person/person_event.dart';
import 'package:shared/bloc/statistics/statistics_bloc.dart';
import 'package:shared/bloc/statistics/statistics_event.dart';
import 'package:shared/bloc/vehicles/vehicles_bloc.dart';
import 'package:shared/bloc/vehicles/vehicles_event.dart';
import 'package:shared/bloc/parking_spaces/parking_space_bloc.dart';
import 'package:shared/bloc/parking_spaces/parking_space_event.dart';
import 'package:shared/bloc/parkings/parking_bloc.dart';
import 'package:shared/bloc/parkings/parking_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AppInitializer());
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<PersonRepository>(
            create: (_) => PersonRepository(),
          ),
          RepositoryProvider<VehicleRepository>(
            create: (_) => VehicleRepository(),
          ),
          RepositoryProvider<ParkingRepository>(
            create: (_) => ParkingRepository(),
          ),
          RepositoryProvider<ParkingSpaceRepository>(
            create: (_) => ParkingSpaceRepository(),
          ),
          RepositoryProvider<AuthRepository>(
            create: (_) => AuthRepository(),
          ),
          RepositoryProvider<UserRepository>(
            create: (_) => UserRepository(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthFirebaseBloc(
                authRepository: context.read<AuthRepository>(),
                userRepository: context.read<UserRepository>(),
              )..add(AuthFirebaseUserSubscriptionRequested()),
            ),
            BlocProvider(
              create: (context) => ParkingBloc(
                parkingRepository: context.read<ParkingRepository>(),
                parkingSpaceRepository: context.read<ParkingSpaceRepository>(),
                vehicleRepository: context.read<VehicleRepository>(),
              )..add(LoadParkings()),
            ),
            BlocProvider(
              create: (context) => VehiclesBloc(
                vehicleRepository: context.read<VehicleRepository>(),
              )..add(LoadVehicles()),
            ),
            BlocProvider(
              create: (context) => PersonBloc(
                personRepository: context.read<PersonRepository>(),
              )..add(LoadPersons()),
            ),
            BlocProvider(
              create: (context) => ParkingSpaceBloc(
                parkingSpaceRepository: context.read<ParkingSpaceRepository>(),
              )..add(LoadParkingSpaces()),
            ),
            BlocProvider(
              create: (context) => StatisticsBloc(
                parkingRepository: context.read<ParkingRepository>(),
                parkingSpaceRepository: context.read<ParkingSpaceRepository>(),
              )..add(LoadStatistics()),
            ),
          ],
          child: const MyApp(),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/login',
      refreshListenable: GoRouterRefreshStream(
        context.read<AuthFirebaseBloc>().stream,
      ),
      redirect: (context, state) {
        final authState = context.read<AuthFirebaseBloc>().state;
        final isLoggedIn = authState is AuthAuthenticated;
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
          path: '/start',
          builder: (context, state) => const NavRailView(initialIndex: 0),
          routes: [
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

    return MaterialApp.router(
      routerConfig: router,
      title: 'Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
    );
  }
}
