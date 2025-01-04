// home_page.dart
import 'package:flutter/material.dart';
import 'package:parking_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';


import '../providers/theme_notifier.dart'; // Ensure the path is correct for your project

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  'Hello, ${authService.username}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    authService.logout();
                    debugPrint('Navigating to StartView from homePage...');
                    context.go('/start');
                  },
                ),
              ],
            ),
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
