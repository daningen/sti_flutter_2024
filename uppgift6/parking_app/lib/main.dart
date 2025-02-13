import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_app/bloc/auth/auth_firebase_bloc.dart';
//final remove
import 'package:parking_app/firebase_options.dart';
import 'package:parking_app/providers/theme_notifier.dart';
import 'package:parking_app/utils/go_router_refresh_stream.dart';
import 'package:parking_app/views/login_view.dart';
import 'package:parking_app/views/start_view.dart';
import 'package:parking_app/views/parking/parking_view.dart';
import 'package:parking_app/views/parking_space/parking_space_view.dart';
import 'package:parking_app/views/person/person_view.dart';
import 'package:parking_app/views/register_view.dart';
import 'package:parking_app/views/statistics_view.dart';
import 'package:parking_app/views/vehicle/vehicles_view.dart';
import 'package:provider/provider.dart';

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
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/app_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => UserRepository(),
        ),
        RepositoryProvider<PersonRepository>(
          create: (_) => PersonRepository(),
        ),
        RepositoryProvider<VehicleRepository>(
          create: (_) => VehicleRepository(),
        ),
        // RepositoryProvider<ParkingRepository>(
        //   create: (_) => ParkingRepository(),
        // ),
        RepositoryProvider<ParkingRepository>(
          create: (context) =>
              ParkingRepository(db: FirebaseFirestore.instance),
        ),
        RepositoryProvider<ParkingSpaceRepository>(
          create: (_) => ParkingSpaceRepository(db: FirebaseFirestore.instance),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthFirebaseBloc(
              authRepository: context.read<AuthRepository>(),
              userRepository: context.read<UserRepository>(),
              personRepository: context
                  .read<PersonRepository>(), // ✅ Fix: Pass PersonRepository
            )..add(AuthFirebaseUserSubscriptionRequested()),
          ),
          BlocProvider(
            create: (context) => PersonBloc(
              personRepository: context.read<PersonRepository>(),
            )..add(LoadPersons()),
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
        child: const AppInitializer(),
      ),
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

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
        final hasCreatedPerson = authState is AuthFirebasePersonCreated;

        // ✅ Ensure person creation leads to login
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
          path: '/', //  root path
          builder: (context, state) => const AppLayout(
            child: StartView(),
          ),
        ),
        GoRoute(
          path: '/start',
          builder: (context, state) => const AppLayout(
            // Use AppLayout
            child:
                StartView(), // Use StartView (NOT NavRailView if it's a Scaffold)
          ),
          routes: [
            GoRoute(
              path: 'statistics',
              builder: (context, state) => const AppLayout(
                // Use AppLayout
                child: StatisticsView(),
              ),
            ),
            GoRoute(
              path: 'parkings',
              // builder: (context, state) => const AppLayout(
              builder: (context, state) => const ParkingView(),
              // child: ParkingView(),
            ),
            GoRoute(
              path: 'parking-spaces',
              builder: (context, state) => const AppLayout(
                child: ParkingSpacesView(),
              ),
            ),
            GoRoute(
              path: 'vehicles',
              builder: (context, state) => const AppLayout(
                child: VehiclesView(),
              ),
            ),
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

    return ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: Builder(
        builder: (context) {
          final themeNotifier = Provider.of<ThemeNotifier>(context);

          return MaterialApp.router(
            routerConfig: router,
            title: 'Parking App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeNotifier.themeMode,
          );
        },
      ),
    );
  }
}
