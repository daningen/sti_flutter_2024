import 'package:admin_app/views/example_view.dart';
import 'package:admin_app/views/parkings_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tjoho Managing App',
      debugShowCheckedModeBanner: false, // Debug banner disabled
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 122, 197, 125),
        ),
        useMaterial3: true, // Ensures Material 3 is used
        scaffoldBackgroundColor:
            const Color.fromARGB(255, 212, 236, 248), // Light background color
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
      label: Text('Example'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.local_parking), // Icon for ParkingView
      selectedIcon: Icon(Icons.local_parking, color: Colors.purple),
      label: Text('Parkings'), // Label for ParkingView
    ),
  ];

  final views = [
    // Replace with actual ItemsView when implemented
    const ExampleView(index: 1),
    const ExampleView(index: 2),
    const ParkingsView(index: 1)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 191, 213, 224), // Explicit background color
      body: Row(
        children: <Widget>[
          NavigationRail(
            backgroundColor:
                const Color.fromARGB(255, 200, 220, 230), // Match theme
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: destinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main content view
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 212, 236, 248), // Match theme
              child: views[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
