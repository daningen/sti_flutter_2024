import 'package:flutter/material.dart';

class ParkingSpacesNavigationBar extends StatelessWidget {
  final Function onHomePressed;
  final Function onReloadPressed;
  final Function onLogoutPressed;

  const ParkingSpacesNavigationBar({
    super.key,
    required this.onHomePressed,
    required this.onReloadPressed,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0, // Set to the appropriate active index
      onTap: (index) {
        switch (index) {
          case 0:
            onHomePressed();
            break;
          case 1:
            onReloadPressed();
            break;
          case 2:
            onLogoutPressed();
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.refresh), label: 'Reload'),
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
      ],
      type: BottomNavigationBarType.fixed, // Ensures all items are shown
    );
  }
}
