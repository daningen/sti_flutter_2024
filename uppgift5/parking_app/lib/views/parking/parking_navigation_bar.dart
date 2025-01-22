import 'package:flutter/material.dart';
import 'package:parking_app/providers/theme_notifier.dart';
import 'package:provider/provider.dart';

class ParkingNavigationBar extends StatelessWidget {
  final Function onHomePressed;
  final Function onShowAllParkings;
  final Function onShowActiveParkings;
  final Function onAddParkingPressed;
  final Function onLogoutPressed;

  const ParkingNavigationBar({
    super.key,
    required this.onHomePressed,
    required this.onShowAllParkings,
    required this.onShowActiveParkings,
    required this.onAddParkingPressed,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeNotifier>(context);

    return BottomNavigationBar(
      currentIndex: 0, // Set to the appropriate active index based on state
      onTap: (index) {
        switch (index) {
          case 0:
            onHomePressed();
            break;
          case 1:
            onShowAllParkings();
            break;
          case 2:
            onShowActiveParkings();
            break;
          case 3:
            onAddParkingPressed();
            break;
          case 4:
            onLogoutPressed();
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'All Parkings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_car),
          label: 'Active Parkings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Logout',
        ),
      ],
      type: BottomNavigationBarType.fixed,
    );
  }
}
