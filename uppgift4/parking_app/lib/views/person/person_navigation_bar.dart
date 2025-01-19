import 'package:flutter/material.dart';

class PersonNavigationBar extends StatelessWidget {
  final Function onHomePressed;
  final Function onReloadPressed;
  final Function onAddPersonPressed;
  final Function onLogoutPressed;

  const PersonNavigationBar({
    super.key,
    required this.onHomePressed,
    required this.onReloadPressed,
    required this.onAddPersonPressed,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0, // Set to the appropriate active index, thought for select to set color. Not completed
      onTap: (index) {
        switch (index) {
          case 0:
            onHomePressed();
            break;
          case 1:
            onReloadPressed();
            break;
          case 2:
            onAddPersonPressed();
            break;
          case 3:
            onLogoutPressed();
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.refresh), label: 'Reload'),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Person'),
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
      ],
      type: BottomNavigationBarType.fixed,  
    );
  }
}
