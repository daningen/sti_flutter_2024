import 'package:admin_app/utils/go_router_refresh_stream.dart';  
import 'package:admin_app/views/parking_spaces/parking_space_view.dart';  
import 'package:admin_app/views/person/person_view.dart';  
import 'package:admin_app/views/register_view.dart';  
import 'package:admin_app/views/statistics_view.dart';  
import 'package:admin_app/views/vehicles/vehicles_view.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';  
import 'package:shared/bloc/auth/auth_firebase_bloc.dart';  
import 'package:firebase_core/firebase_core.dart';  
import 'package:firebase_repositories/firebase_repositories.dart';  
import 'package:flutter/material.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:go_router/go_router.dart';  
import 'package:provider/provider.dart'; // Provider for state management (ThemeNotifier)
import 'package:admin_app/firebase_options.dart';  
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
import 'package:cloud_firestore/cloud_firestore.dart';  

// Main function to initialize Firebase and run the app
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
            )..add(const LoadParkings()), // Load parkings initially
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

// Widget to initialize the app's routing and theme
class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    // Configure GoRouter for navigation
    final router = GoRouter(
      initialLocation: '/login',  
      refreshListenable: GoRouterRefreshStream(  
        context.read<AuthFirebaseBloc>().stream,  
      ),
      redirect: (context, state) {
        final authState = context.read<AuthFirebaseBloc>().state;  
        final isLoggedIn = authState is AuthAuthenticated;  
        final isRegistering = state.uri.toString() == '/register';  
        final isPendingRegistration = authState is AuthUnauthenticated &&  
            authState.errorMessage ==
                'Pending person creation';

        debugPrint(
            'Redirect Logic: state=${state.uri.toString()}, isLoggedIn=$isLoggedIn, isRegistering=$isRegistering, isPendingRegistration=$isPendingRegistration');

        if (isPendingRegistration) {
          return '/register';  
        }

        if (!isLoggedIn && !isRegistering) {
          return '/login';  
        }

        if (isLoggedIn) {
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
        GoRoute( // Start route (main app)
          path: '/start',
          builder: (context, state) => const NavRailView(initialIndex: 0),
          routes: [ // Sub-routes for the main app
            GoRoute(  
              path: 'statistics',
              builder: (context, state) => const StatisticsView(),
            ),
            GoRoute( 
              path: 'parkings',
              builder: (context, state) => const ParkingSpacesView(),
            ),
            GoRoute(  
              path: 'parking-spaces',
              builder: (context, state) => const ParkingSpacesView(),
            ),
            GoRoute(  
              path: 'vehicles',
              builder: (context, state) => const VehiclesView(),
            ),
            GoRoute(  
              path: 'persons',
              builder: (context, state) => const PersonView(),
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
            title: 'Admin Dashboard',
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
