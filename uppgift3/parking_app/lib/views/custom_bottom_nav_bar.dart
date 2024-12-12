import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final String currentRoute;

  const CustomBottomNavigationBar({required this.currentRoute, super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _getIndexForRoute(currentRoute),
      onTap: (index) => _handleNavigation(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.refresh), label: 'Reload'),
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
      ],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        if (currentRoute != '/') {
          context.go('/'); //   to Home
        }
        break;
      case 1:
        // Reload the current page
        _reloadPage(context);
        break;
      case 2:
        // Handle logout logic
        _logout(context);
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
              context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
