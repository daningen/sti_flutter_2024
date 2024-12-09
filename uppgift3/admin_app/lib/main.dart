import 'package:admin_app/views/example_view.dart';
import 'package:admin_app/views/items_view.dart';
import 'package:admin_app/views/parking_space_view.dart';

import 'package:admin_app/views/parking_view.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Managing App',
      debugShowCheckedModeBanner: false, // Debug banner disabled
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 159, 185, 138),
        ),
        useMaterial3: true, // Ensures Material 3 is used
        scaffoldBackgroundColor:
            const Color.fromARGB(255, 102, 126, 105), // Light background color
      ),
      home: const NavRailView(),
    );
  }
}

class NavRailView extends StatefulWidget {
  const NavRailView({super.key});

  @override
  State<NavRailView> createState() => _NavRailViewState();
}

class _NavRailViewState extends State<NavRailView> {
  int _selectedIndex = 0;

  final destinations = const <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.favorite_border),
      selectedIcon: Icon(Icons.favorite),
      label: Text('Items'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.bookmark_border),
      selectedIcon: Icon(Icons.book),
      label: Text('Statistics'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.car_repair_sharp), // Icon for ParkingView
      selectedIcon: Icon(Icons.car_repair_sharp,
          color: Color.fromARGB(255, 242, 153, 45)),
      label: Text('Parkings'), // Label for ParkingView
    ),
    NavigationRailDestination(
      icon: Icon(Icons.local_parking), // Icon for Parking space
      selectedIcon:
          Icon(Icons.local_parking, color: Color.fromARGB(255, 242, 153, 45)),
      label: Text('Parking space'), // Label for ParkingView
    ),
  ];

  final views = [
    const ItemsView(index: 1),
    const ExampleView(index: 2),
    const ParkingView(),
    const ParkingSpacesView(index: 3)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 154, 179, 148), // Explicit background color
      body: Row(
        children: <Widget>[
          NavigationRail(
            backgroundColor:
                const Color.fromARGB(255, 167, 188, 162), // Match theme
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index; //index is set when choosing a
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: destinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main content view
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 200, 204, 207), // Match theme
              child: views[_selectedIndex], //showing the rest of the page
            ),
          ),
        ],
      ),
    );
  }
}
