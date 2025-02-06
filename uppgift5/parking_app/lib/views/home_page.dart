import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/bloc/auth/auth_event.dart';

import '../providers/theme_notifier.dart';
import 'package:shared/bloc/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/bloc/auth/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(
              themeNotifier.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              themeNotifier.toggleTheme();
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        'Hello, ${state.username}', // Access username from AuthAuthenticated state
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () {
                          context.read<AuthBloc>().add(LogoutRequested());
                          debugPrint(
                              'Navigating to StartView from HomePage...');
                          context.go('/login');
                        },
                      ),
                    ],
                  ),
                );
              } else {
                // Handle unauthenticated state (e.g., display a message or redirect)
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Home Page!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/user-page'),
              child: const Text('Users'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/my-vehicles'),
              child: const Text('Vehicles'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/parking-spaces'),
              child: const Text('Parking Spaces'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/parking'),
              child: const Text('Parking'),
            ),
          ],
        ),
      ),
    );
  }
}
