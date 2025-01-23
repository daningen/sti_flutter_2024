import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:admin_app/firebase_options.dart';
import 'package:admin_app/services/auth_service.dart';
import 'package:shared/bloc/auth/auth_bloc.dart';
import 'package:shared/bloc/auth/auth_state.dart';
import 'package:shared/bloc/parking_spaces/parking_space_event.dart';
import 'package:shared/bloc/parkings/parking_event.dart';
import 'package:shared/bloc/person/person_bloc.dart';
import 'package:shared/bloc/person/person_event.dart';
import 'package:shared/bloc/vehicles/vehicles_bloc.dart';
import 'package:shared/bloc/parking_spaces/parking_space_bloc.dart';
import 'package:shared/bloc/parkings/parking_bloc.dart';
import 'package:shared/bloc/vehicles/vehicles_event.dart';
import 'theme_notifier.dart';
import 'views/nav_rail_view.dart';
import 'views/login_view.dart';

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
            create: (context) => PersonRepository(),
          ),
          RepositoryProvider<VehicleRepository>(
            create: (context) => VehicleRepository(),
          ),
          RepositoryProvider<ParkingRepository>(
            create: (context) => ParkingRepository(),
          ),
          RepositoryProvider<ParkingSpaceRepository>(
            create: (context) => ParkingSpaceRepository(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthBloc(
                authService: AuthService(),
              ),
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
          ],
          child: MyApp(),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final router = GoRouter(
    initialLocation: '/start',
    routes: [
      // Define your routes here if needed.
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
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return NavRailView(
              router: router,
              initialIndex: 0,
            );
          } else {
            return const LoginView();
          }
        },
      ),
    );
  }
}
