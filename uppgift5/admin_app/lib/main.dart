// ignore_for_file: prefer_const_constructors

import 'package:admin_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:shared/bloc/parking_spaces/parking_space_bloc.dart';
import 'package:shared/bloc/parking_spaces/parking_space_event.dart';
import 'package:shared/bloc/parkings/parking_bloc.dart';
import 'package:shared/bloc/parkings/parking_event.dart';
import 'package:shared/bloc/person/person_bloc.dart';
import 'package:shared/bloc/person/person_event.dart';
import 'package:admin_app/services/auth_service.dart';
import 'package:admin_app/views/person/person_view.dart';
import 'package:shared/bloc/auth/auth_bloc.dart';
import 'package:shared/bloc/auth/auth_state.dart';
import 'package:admin_app/views/login_view.dart';
import 'package:admin_app/views/nav_rail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared/bloc/vehicles/vehicles_bloc.dart';
import 'package:shared/bloc/vehicles/vehicles_event.dart';
import 'theme_notifier.dart';
import 'views/parking_spaces/parking_space_view.dart';
import 'views/parking/parking_view.dart';
import 'views/start_view.dart';
import 'views/statistics_view.dart';
import 'views/vehicles/vehicles_view.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized before calling Firebase
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with the appropriate options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Instantiate services and repositories
    final authService = AuthService();
    final parkingRepository = ParkingRepository();
    final parkingSpaceRepository = ParkingSpaceRepository();
    final vehicleRepository = VehicleRepository();
    final personRepository = PersonRepository();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => AuthBloc(authService: authService),
            ),
            BlocProvider(
              create: (_) => ParkingBloc(
                parkingRepository: parkingRepository,
                parkingSpaceRepository: parkingSpaceRepository,
                vehicleRepository: vehicleRepository,
              )..add(LoadParkings()),
            ),
            BlocProvider(
              create: (_) => VehiclesBloc(vehicleRepository: vehicleRepository)
                ..add(LoadVehicles()),
            ),
            BlocProvider(
              create: (_) => PersonBloc(personRepository: personRepository)
                ..add(LoadPersons()),
            ),
            BlocProvider(
              create: (_) => ParkingSpaceBloc(
                parkingSpaceRepository: parkingSpaceRepository,
              )..add(LoadParkingSpaces()),
            ),
          ],
          child: MyApp(),
        ),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Error initializing app: $e');
    debugPrint('Stack trace: $stackTrace');
  }
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
        path: '/persons',
        builder: (context, state) => const PersonView(),
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
