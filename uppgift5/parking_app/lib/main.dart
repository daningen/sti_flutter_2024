import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/firebase_options.dart';
import 'package:parking_app/views/person/person_view.dart';
import 'package:parking_app/views/register_view.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:shared/bloc/parking_spaces/parking_space_event.dart';
import 'package:shared/bloc/parkings/parking_event.dart';
import 'package:shared/bloc/person/person_bloc.dart';
import 'package:shared/bloc/person/person_event.dart';
import 'package:shared/bloc/vehicles/vehicles_event.dart';

import 'app_theme.dart';
import 'services/auth_service.dart';
import 'providers/theme_notifier.dart';

import 'views/start_view.dart';
import 'views/vehicle/vehicles_view.dart';
import 'views/login_view.dart';
import 'views/home_page.dart';
import 'views/parking/parking_view.dart';
import 'views/parking_space/parking_space_view.dart';
import 'package:shared/bloc/auth/auth_bloc.dart';
import 'package:shared/bloc/parkings/parking_bloc.dart';
import 'package:shared/bloc/vehicles/vehicles_bloc.dart';
import 'package:shared/bloc/parking_spaces/parking_space_bloc.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized before calling Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the appropriate options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Instantiate required services and repositories
  final authService = AuthService();
  final parkingRepository = ParkingRepository();
  final vehicleRepository = VehicleRepository();
  final parkingSpaceRepository = ParkingSpaceRepository();

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
            create: (_) => _initializeParkingBloc(
              parkingRepository,
              parkingSpaceRepository,
              vehicleRepository,
            ),
          ),
          BlocProvider(
            create: (_) => _initializeVehiclesBloc(vehicleRepository),
          ),
          BlocProvider(
            create: (_) => _initializeParkingSpaceBloc(parkingSpaceRepository),
          ),
          BlocProvider(
            create: (_) {
              final personBloc =
                  PersonBloc(personRepository: PersonRepository());
              personBloc.add(LoadPersons()); // Dispatch initial event
              return personBloc;
            },
          ),
          BlocProvider(
            create: (_) => ParkingSpaceBloc(
              parkingSpaceRepository: ParkingSpaceRepository(),
            )..add(LoadParkingSpaces()),
          ),
        ],
        child: ParkingApp(),
      ),
    ),
  );
}

/// Initialize and return the [ParkingBloc] with its initial event
ParkingBloc _initializeParkingBloc(
  ParkingRepository parkingRepository,
  ParkingSpaceRepository parkingSpaceRepository,
  VehicleRepository vehicleRepository,
) {
  final bloc = ParkingBloc(
    parkingRepository: parkingRepository,
    parkingSpaceRepository: parkingSpaceRepository,
    vehicleRepository: vehicleRepository,
  );
  bloc.add(LoadParkings()); // Load initial parkings
  return bloc;
}

/// Initialize and return the [VehiclesBloc] with its initial event
VehiclesBloc _initializeVehiclesBloc(VehicleRepository vehicleRepository) {
  final bloc = VehiclesBloc(vehicleRepository: vehicleRepository);
  bloc.add(LoadVehicles()); // Load initial vehicles
  return bloc;
}

/// Initialize and return the [ParkingSpaceBloc] with its initial event
ParkingSpaceBloc _initializeParkingSpaceBloc(
  ParkingSpaceRepository parkingSpaceRepository,
) {
  final bloc = ParkingSpaceBloc(parkingSpaceRepository: parkingSpaceRepository);
  bloc.add(LoadParkingSpaces()); // Load initial parking spaces
  return bloc;
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
        builder: (context, state) => const PersonView(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Parking App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: context.watch<ThemeNotifier>().themeMode,
      routerConfig: _router,
    );
  }
}
