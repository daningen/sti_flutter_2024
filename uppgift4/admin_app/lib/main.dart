// ignore_for_file: prefer_const_constructors

import 'package:admin_app/bloc/parkings/parking_event.dart';
import 'package:admin_app/bloc/person/person_bloc.dart';
import 'package:admin_app/bloc/person/person_event.dart';
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

import 'theme_notifier.dart';
import 'bloc/parkings/parking_bloc.dart';
import 'bloc/vehicles/vehicles_bloc.dart';
import 'bloc/vehicles/vehicles_event.dart';
import 'bloc/parking_spaces/parking_space_bloc.dart';
import 'bloc/parking_spaces/parking_space_event.dart';
import 'views/parking_spaces/parking_space_view.dart';
import 'views/parking/parking_view.dart';
import 'views/start_view.dart';
import 'views/statistics_view.dart';

import 'views/vehicles/vehicles_view.dart';
import 'package:client_repositories/async_http_repos.dart';

void main() {
  final authService = AuthService();
  final parkingRepository = ParkingRepository();
  final parkingSpaceRepository = ParkingSpaceRepository();
  final vehicleRepository = VehicleRepository();

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
            ),
          ),
          BlocProvider<VehiclesBloc>(
            create: (context) {
              final bloc = VehiclesBloc(vehicleRepository: vehicleRepository);
              bloc.add(
                  LoadVehicles()); // Ensure the bloc loads vehicles initially
              return bloc;
            },
          ),
          BlocProvider<PersonBloc>(
            create: (context) {
              final bloc = PersonBloc(personRepository: PersonRepository());
              bloc.add(LoadPersons());
              return bloc;
            },
          ),
          BlocProvider<ParkingSpaceBloc>(
            create: (context) {
              final bloc = ParkingSpaceBloc(
                  parkingSpaceRepository: parkingSpaceRepository);
              bloc.add(
                  LoadParkingSpaces()); // Ensure the bloc loads parking spaces initially
              return bloc;
            },
          ),
          BlocProvider<ParkingBloc>(
  create: (context) {
    final bloc = ParkingBloc(
      parkingRepository: parkingRepository,
      vehicleRepository: vehicleRepository,
      parkingSpaceRepository: parkingSpaceRepository,
    );
    bloc.add(LoadParkings()); // Ensure the bloc loads parkings initially
    return bloc;
  },
),

        ],
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
