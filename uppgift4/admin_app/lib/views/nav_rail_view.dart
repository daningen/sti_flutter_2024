import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'start_view.dart';
import 'statistics_view.dart';
import 'parking_view.dart';
import 'parking_space_view.dart';
import 'vehicles_view.dart';
import 'user_view.dart';

class NavRailView extends StatefulWidget {
  final GoRouter router;
  final int initialIndex;

  const NavRailView(
      {required this.router, required this.initialIndex, super.key});

  @override
  State<NavRailView> createState() => _NavRailViewState();
}

class _NavRailViewState extends State<NavRailView> {
  late int _selectedIndex;
  bool _isRailExtended = false;

  final List<String> routes = [
    '/start',
    '/statistics',
    '/parkings',
    '/parking-spaces',
    '/vehicles',
    '/users',
  ];

  final List<NavigationRailDestination> destinations = [
    const NavigationRailDestination(
      icon: Icon(Icons.home),
      label: Text('Start'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.bar_chart),
      label: Text('Statistics'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.car_repair_sharp),
      label: Text('Parkings'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.local_parking),
      label: Text('Parking Spaces'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.directions_car),
      label: Text('Vehicles'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.people),
      label: Text('Users'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          MouseRegion(
            onEnter: (_) {
              setState(() {
                _isRailExtended = true;
              });
            },
            onExit: (_) {
              setState(() {
                _isRailExtended = false;
              });
            },
            child: NavigationRail(
              extended: _isRailExtended,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                  widget.router.go(routes[index]); // Navigate using GoRouter
                });
              },
              destinations: destinations,
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                StartView(),
                StatisticsView(),
                ParkingView(),
                ParkingSpacesView(),
                VehiclesView(),
                UserView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
