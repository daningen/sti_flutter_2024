// import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notification_utils/notification_utils.dart';
// import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:provider/provider.dart';
import 'package:shared/bloc/auth/auth_firebase_bloc.dart';
import 'package:shared/bloc/person/person_bloc.dart';
import 'package:shared/bloc/person/person_event.dart';
import 'package:shared/bloc/statistics/statistics_bloc.dart';
import 'package:shared/bloc/statistics/statistics_event.dart';
import 'package:shared/bloc/vehicles/vehicles_bloc.dart';
import 'package:shared/bloc/vehicles/vehicles_event.dart';
import 'router.dart'; // Import the router file
import 'package:shared/bloc/parking_spaces/parking_space_bloc.dart';
import 'package:shared/bloc/parking_spaces/parking_space_event.dart';
import 'package:shared/bloc/parkings/parking_bloc.dart';
import 'package:shared/bloc/parkings/parking_event.dart';

import 'package:parking_app/firebase_options.dart';
import 'package:parking_app/providers/theme_notifier.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import the local notifications plugin




final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await configureLocalTimeZone(); // Configure timezone before initializing notifications

// Android-inställningar
  var initializationSettingsAndroid = const AndroidInitializationSettings(
      '@mipmap/ic_launcher'); // Eller använd egen ikon: '@drawable/ic_notification'

  // iOS-inställningar
  // var initializationSettingsIOS = const DarwinInitializationSettings();

  // Kombinera plattformsinställningar
  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
        RepositoryProvider<UserRepository>(create: (_) => UserRepository()),
        RepositoryProvider<PersonRepository>(create: (_) => PersonRepository()),
        RepositoryProvider<VehicleRepository>(
            create: (_) => VehicleRepository()),
        RepositoryProvider<ParkingRepository>(
            create: (_) => ParkingRepository(db: FirebaseFirestore.instance)),
        RepositoryProvider<ParkingSpaceRepository>(
            create: (_) =>
                ParkingSpaceRepository(db: FirebaseFirestore.instance)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthFirebaseBloc(
              authRepository: context.read<AuthRepository>(),
              userRepository: context.read<UserRepository>(),
              personRepository: context.read<PersonRepository>(),
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
    final router = createRouter(context); // separate file `router.dart`

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
