// import 'dart:io';

import 'dart:io';

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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await configureLocalTimeZone();
  await requestPermissions(); // Request permissions BEFORE initialization

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
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
  );

  debugPrint("Notification initialized: $isInitialized");
  // if (isInitialized != null && isInitialized) {
  //   Future.delayed(Duration(seconds: 5), () async {
  //     await showTestNotification();
  //   });
  // } else {
  //   debugPrint(
  //       "Failed to initialize notifications. Test notification not sent.");
  // }

  runApp(const MyApp());
}

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

void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) {
  debugPrint('Notification tapped: ${notificationResponse.payload}');
  if (notificationResponse.payload != null) {
    navigatorKey.currentState
        ?.pushNamed('/parkings', arguments: notificationResponse.payload);
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
    final router = createRouter(context);

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
