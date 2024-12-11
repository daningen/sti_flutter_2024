import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.refresh),
          label: 'Reload',
        ),
      ],
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/'); // Navigate to the home page
        break;
      case 1:
        final currentRoute = GoRouter.of(context).location;
        if (currentRoute == '/user-page') {
          // Custom reload action for UserPage
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reloading users...')),
          );
          Navigator.pushReplacementNamed(context, currentRoute); // Reload page
        }
        break;
      default:
        break;
    }
  }
}
