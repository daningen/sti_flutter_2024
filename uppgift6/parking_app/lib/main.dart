import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notification_utils/notification_utils.dart';
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


// Initialize FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Global key for navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initialize Firebase
  );

  await configureLocalTimeZone(); // Configure the local timezone for notifications
  await requestPermissions(); // Request notification permissions

  // Android initialization settings
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS initialization settings
  var initializationSettingsIOS = const DarwinInitializationSettings();

  // Combine platform-specific settings
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  debugPrint("Initializing notifications...");
  var isInitialized = await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse, // Callback for notification taps
  );

  debugPrint("Notification initialized: $isInitialized");
  

  runApp(const MyApp()); // Run the app
}

// Function to request notification permissions
Future<void> requestPermissions() async {
  debugPrint("Requesting notification permissions...");
  if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  } else if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
}

// Function to show a test notification (for debugging)
Future<void> showTestNotification() async {
  debugPrint("Showing test notification...");

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id',
    'Test Channel',
    importance: Importance.high,
    priority: Priority.high,
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails, iOS: iosDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Test Notification',
    'This is a test notification',
    platformDetails,
    payload: 'test_payload',
  );

  debugPrint("Test notification should be visible.");
}

// Callback function for when a notification is tapped
void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) {
  debugPrint('Notification tapped: ${notificationResponse.payload}');
  if (notificationResponse.payload != null) {
    navigatorKey.currentState?.pushNamed('/parkings',
        arguments: notificationResponse.payload); // Navigate to parkings view
  }
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
        create: (_) => VehicleRepository(db: FirebaseFirestore.instance)),
    RepositoryProvider<ParkingSpaceRepository>( // Move this up!
        create: (_) =>
            ParkingSpaceRepository(db: FirebaseFirestore.instance)),
    RepositoryProvider<ParkingRepository>(
        create: (context) => ParkingRepository(
            db: FirebaseFirestore.instance,
            parkingSpaceRepository: context.read<ParkingSpaceRepository>(),
        )),
  ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthFirebaseBloc(
              authRepository: context.read<AuthRepository>(),
              userRepository: context.read<UserRepository>(),
              personRepository: context.read<PersonRepository>(),
            )..add(AuthFirebaseUserSubscriptionRequested()), // Subscribe to user changes
          ),
          BlocProvider(
            create: (context) => PersonBloc(
              personRepository: context.read<PersonRepository>(),
            )..add(LoadPersons()), // Load persons initially
          ),
          BlocProvider(
            create: (context) => ParkingBloc(
              parkingRepository: context.read<ParkingRepository>(),
              parkingSpaceRepository: context.read<ParkingSpaceRepository>(),
              vehicleRepository: context.read<VehicleRepository>(),
              authFirebaseBloc: context.read<AuthFirebaseBloc>(),
              // notificationService: context.read<NotificationService>(), // Inject NotificationService
            )..add(LoadParkings()), // Load parkings initially
          ),
          BlocProvider(
            create: (context) => VehiclesBloc(
              vehicleRepository: context.read<VehicleRepository>(),
              authFirebaseBloc: context.read<AuthFirebaseBloc>(),
            )..add(LoadVehicles()), // Load vehicles initially
          ),
          BlocProvider(
            create: (context) => ParkingSpaceBloc(
              parkingSpaceRepository: context.read<ParkingSpaceRepository>(),
            )..add(LoadParkingSpaces()), // Load parking spaces initially
          ),
          BlocProvider(
            create: (context) => StatisticsBloc(
              parkingRepository: context.read<ParkingRepository>(),
              parkingSpaceRepository: context.read<ParkingSpaceRepository>(),
            )..add(LoadStatistics()), // Load statistics initially
          ),
        ],
        child: const AppInitializer(), // Initialize the app
      ),
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createRouter(context); // Create the router

    return ChangeNotifierProvider(
      create: (context) => ThemeNotifier(), // Provide the theme notifier
      child: Builder(
        builder: (context) {
          final themeNotifier = Provider.of<ThemeNotifier>(context); // Access the theme notifier

          return MaterialApp.router(
            routerConfig: router, // Set the router configuration
            title: 'Parking App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(), // Set light theme
            darkTheme: ThemeData.dark(), // Set dark theme
            themeMode: themeNotifier.themeMode, // Set theme mode
          );
        },
      ),
    );
  }
}