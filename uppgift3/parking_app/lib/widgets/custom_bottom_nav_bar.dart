import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final String currentRoute;

  const CustomBottomNavigationBar({required this.currentRoute, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).bottomNavigationBarTheme;

    return BottomNavigationBar(
      currentIndex: _getIndexForRoute(currentRoute),
      onTap: (index) => _handleNavigation(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.refresh), label: 'Reload'),
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
      ],
      selectedItemColor: theme.selectedItemColor ?? Colors.blue,
      unselectedItemColor: theme.unselectedItemColor ??
          Colors.lightGreen, // Overwritten by main.dart
      backgroundColor:
          theme.backgroundColor ?? const Color.fromARGB(255, 101, 106, 180),
      showSelectedLabels: theme.showSelectedLabels ?? true,
      showUnselectedLabels: theme.showUnselectedLabels ?? true,
      type: BottomNavigationBarType.fixed,
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        if (currentRoute != '/') {
          context.go('/'); // Navigate to Home
        }
        break;
      case 1:
        _reloadPage(context); // Reload the current page
        break;
      case 2:
        _logout(context); // Handle logout logic
        break;
    }
  }

  int _getIndexForRoute(String route) {
    switch (route) {
      case '/':
        return 0;
      default:
        return 0; // Default to Home
    }
  }

  void _reloadPage(BuildContext context) {
    context.go(currentRoute); // Navigate to the same route to refresh the page
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
              context.go('/start'); // Redirect to the start page
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
