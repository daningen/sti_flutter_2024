import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared/bloc/auth/auth_firebase_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:admin_app/firebase_options.dart';
import 'package:admin_app/theme_notifier.dart';
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

// Import the router file
import 'router.dart'; // Import the router file

// Initialize FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Global key for navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

// Main app widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiRepositoryProvider to provide repositories to the app
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
        RepositoryProvider<UserRepository>(create: (_) => UserRepository()),
        RepositoryProvider<PersonRepository>(create: (_) => PersonRepository()),
        RepositoryProvider<VehicleRepository>(
            create: (_) => VehicleRepository(db: FirebaseFirestore.instance)),
        RepositoryProvider<ParkingSpaceRepository>(
            create: (_) =>
                ParkingSpaceRepository(db: FirebaseFirestore.instance)),
        RepositoryProvider<ParkingRepository>(
          create: (context) => ParkingRepository(
            db: FirebaseFirestore.instance,
            parkingSpaceRepository: context.read<ParkingSpaceRepository>(),
          ),
        ),
      ],
      // MultiBlocProvider to provide Blocs to the app
      child: MultiBlocProvider(
        providers: [
          // AuthFirebaseBloc for authentication
          BlocProvider(
            create: (context) => AuthFirebaseBloc(
              authRepository: context.read<AuthRepository>(),
              userRepository: context.read<UserRepository>(),
              personRepository: context.read<PersonRepository>(),
            )..add(AuthFirebaseUserSubscriptionRequested()),
          ),
          // PersonBloc for managing persons
          BlocProvider(
            create: (context) => PersonBloc(
              personRepository: context.read<PersonRepository>(),
            )..add(LoadPersons()),
          ),
          // ParkingBloc for managing parkings
          BlocProvider(
            create: (context) => ParkingBloc(
              parkingRepository: context.read<ParkingRepository>(),
              parkingSpaceRepository: context.read<ParkingSpaceRepository>(),
              vehicleRepository: context.read<VehicleRepository>(),
              authFirebaseBloc: context.read<AuthFirebaseBloc>(),
            )..add(const LoadParkings()),
          ),
          // VehiclesBloc for managing vehicles
          BlocProvider(
            create: (context) => VehiclesBloc(
              vehicleRepository: context.read<VehicleRepository>(),
              authFirebaseBloc: context.read<AuthFirebaseBloc>(),
            )..add(LoadVehicles()),
          ),
          // ParkingSpaceBloc for managing parking spaces
          BlocProvider(
            create: (context) => ParkingSpaceBloc(
              parkingSpaceRepository: context.read<ParkingSpaceRepository>(),
            )..add(LoadParkingSpaces()),
          ),
          // StatisticsBloc for managing statistics
          BlocProvider(
            create: (context) => StatisticsBloc(
              parkingRepository: context.read<ParkingRepository>(),
              parkingSpaceRepository: context.read<ParkingSpaceRepository>(),
            )..add(LoadStatistics()),
          ),
        ],
        // AppInitializer widget to initialize routing and theme
        child: const AppInitializer(),
      ),
    );
  }
}

// Widget to initialize the app's routing and theme
class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    // Create the router using the function from router.dart
    final router = createRouter(context);

    // ChangeNotifierProvider for ThemeNotifier to manage app theme
    return ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      // Wrap MultiBlocProvider with ChangeNotifierProvider
      child: MultiBlocProvider(
        providers: [
          // AuthFirebaseBloc for authentication
          BlocProvider(
            create: (context) => AuthFirebaseBloc(
              authRepository: context.read<AuthRepository>(),
              userRepository: context.read<UserRepository>(),
              personRepository: context.read<PersonRepository>(),
            )..add(AuthFirebaseUserSubscriptionRequested()),
          ),
          // PersonBloc for managing persons
          BlocProvider(
            create: (context) => PersonBloc(
              personRepository: context.read<PersonRepository>(),
            )..add(LoadPersons()),
          ),
          // ParkingBloc for managing parkings
          BlocProvider(
            create: (context) => ParkingBloc(
              parkingRepository: context.read<ParkingRepository>(),
              parkingSpaceRepository: context.read<ParkingSpaceRepository>(),
              vehicleRepository: context.read<VehicleRepository>(),
              authFirebaseBloc: context.read<AuthFirebaseBloc>(),
            )..add(const LoadParkings()),
          ),
          // VehiclesBloc for managing vehicles
          BlocProvider(
            create: (context) => VehiclesBloc(
              vehicleRepository: context.read<VehicleRepository>(),
              authFirebaseBloc: context.read<AuthFirebaseBloc>(),
            )..add(LoadVehicles()),
          ),
          // ParkingSpaceBloc for managing parking spaces
          BlocProvider(
            create: (context) => ParkingSpaceBloc(
              parkingSpaceRepository: context.read<ParkingSpaceRepository>(),
            )..add(LoadParkingSpaces()),
          ),
          // StatisticsBloc for managing statistics
          BlocProvider(
            create: (context) => StatisticsBloc(
              parkingRepository: context.read<ParkingRepository>(),
              parkingSpaceRepository: context.read<ParkingSpaceRepository>(),
            )..add(LoadStatistics()),
          ),
        ],
        // Builder widget to access the context with providers
        child: Builder(
          builder: (context) {
            // Access ThemeNotifier from the context
            final themeNotifier = Provider.of<ThemeNotifier>(context);

            // MaterialApp.router to initialize routing and theme
            return MaterialApp.router(
              routerConfig: router,
              title: 'Admin Dashboard',
              debugShowCheckedModeBanner: false,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: themeNotifier.themeMode,
            );
          },
        ),
      ),
    );
  }
}