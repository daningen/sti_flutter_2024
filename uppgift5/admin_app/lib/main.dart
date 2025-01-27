// ignore_for_file: duplicate_import

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
      initialLocation: '/start',
      routes: [
        //
      ],
    );

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
      home: BlocBuilder<AuthFirebaseBloc, AuthState>(
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
