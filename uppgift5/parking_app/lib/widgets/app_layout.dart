import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../bloc/auth/auth_firebase_bloc.dart';

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child, // The actual page content
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Using GoRouter's `routerDelegate.currentConfiguration.fullPath` for current location
    final String location =
        GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;

    debugPrint('🟢 Current Route: $location');

    return BottomNavigationBar(
      currentIndex: _getIndexForRoute(location),
      onTap: (index) => _handleNavigation(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.local_parking), label: 'Parkings'),
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
      ],
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    final routes = [
      '/', // Root path - CORRECTED
      '/start/parkings', // Corrected to /start/parkings
      '/logout',
    ];

    if (index == 2) {
      // Handle logout separately
      _logout(context);
    } else {
      debugPrint('🔵 Navigating to ${routes[index]}');
      context.go(routes[index]);
    }
  }

  int _getIndexForRoute(String route) {
    // Determine the active tab based on the current route
    if (route.startsWith('/home/parking')) return 1;
    if (route == '/home') return 0;
    return 2; // Logout index by default
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              debugPrint('🔴 Redirecting to login screen after logout');
              context
                  .read<AuthFirebaseBloc>()
                  .add(LogoutRequested()); // Dispatch LogoutRequested
              context.go('/login'); // Redirect to login after logout
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
