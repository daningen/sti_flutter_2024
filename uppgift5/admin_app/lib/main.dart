import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

import 'package:admin_app/views/login_view.dart';
import 'package:admin_app/views/register_view.dart';
import 'package:admin_app/views/nav_rail_view.dart';
import 'firebase_options.dart';
import 'utils/go_router_refresh_stream.dart';

import 'package:admin_app/bloc/auth/auth_firebase_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully.');

    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      debugPrint('Firebase Auth User Changed: $user');
    });
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => UserRepository(),
        ),
      ],
      child: BlocProvider(
        create: (context) => AuthFirebaseBloc(
          authRepository: context.read<AuthRepository>(),
          userRepository: context.read<UserRepository>(),
        )..add(AuthFirebaseUserSubscriptionRequested()),
        child: const AppRouter(),
      ),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthFirebaseBloc>();

    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterView(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => NavRailView(
            router: GoRouter.of(context),
            initialIndex: 0,
          ),
        ),
      ],
      redirect: (context, state) {
        final authState = authBloc.state;

        if (authState is AuthAuthenticated &&
            state.uri.toString() == '/login') {
          return '/home';
        } else if (authState is! AuthAuthenticated &&
            (state.uri.toString() == '/home' ||
                state.uri.toString() == '/register')) {
          return '/login';
        }
        return null;
      },
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
    );

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
    );
  }
}
