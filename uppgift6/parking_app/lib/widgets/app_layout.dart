import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared/bloc/auth/auth_firebase_bloc.dart';

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child, // The actual page content
      bottomNavigationBar: const CustomBottomNavigationBar(), // ✅ Bottom Navigation added
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Fix: Get the current path safely
    final String location =
        GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;

    debugPrint('🟢 Current Route: $location');

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // ✅ Fix: Ensure visibility
      currentIndex: _getIndexForRoute(location),
      onTap: (index) => _handleNavigation(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.local_parking), label: 'Parkings'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Vehicles'), // ✅ Fix: Vehicles tab added
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
      ],
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    final routes = [
      '/start', // ✅ Fix: Ensure proper path
      '/start/parkings',
      '/start/vehicles',
      '/logout',
    ];

    if (index == 3) {
      _logout(context);
    } else {
      debugPrint('🔵 Navigating to ${routes[index]}');
      context.go(routes[index]); // ✅ Fix: Use GoRouter
    }
  }

  int _getIndexForRoute(String? route) {
    if (route == '/' || route == '/start') return 0; // ✅ Fix: Ensure Home is selected correctly
    if (route?.startsWith('/start/parkings') ?? false) return 1;
    if (route?.startsWith('/start/vehicles') ?? false) return 2;
    return 3; // ✅ Default to logout tab
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
              context.read<AuthFirebaseBloc>().add(LogoutRequested()); // Dispatch LogoutRequested
              context.go('/login'); // Redirect to login after logout
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
