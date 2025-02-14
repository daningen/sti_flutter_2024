import 'package:flutter/material.dart';

class ParkingSpacesNavigationBar extends StatelessWidget {
  final VoidCallback onHomePressed;
  final VoidCallback onReloadPressed;
  final VoidCallback onLogoutPressed;
  final VoidCallback onAddParkingSpace;  

  const ParkingSpacesNavigationBar({
    super.key,
    required this.onHomePressed,
    required this.onReloadPressed,
    required this.onLogoutPressed,
    required this.onAddParkingSpace,  
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: onHomePressed,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onReloadPressed,
          ),
          IconButton(
            icon: const Icon(Icons.add), 
            onPressed: onAddParkingSpace, 
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogoutPressed,
          ),
        ],
      ),
    );
  }
}
