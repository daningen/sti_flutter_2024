import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'start_view.dart';
import 'statistics_view.dart';
import 'parking_view.dart';
import 'parking_spaces/parking_space_view.dart';
import 'vehicles/vehicles_view.dart';
import 'person/person_view.dart'; // Update to import PersonView

import 'package:shared/shared.dart';

class NavRailView extends StatefulWidget {
  final GoRouter router;
  final int initialIndex;
  final Parking? selectedParking;

  const NavRailView({
    required this.router,
    required this.initialIndex,
    this.selectedParking,
    super.key,
  });

  @override
  State<NavRailView> createState() => _NavRailViewState();
}

class _NavRailViewState extends State<NavRailView> {
  late int _selectedIndex;

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
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
                widget.router.go(_getRoute(index));
              });
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Start'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                label: Text('Statistics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_parking),
                label: Text('Parkings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_parking),
                label: Text('Parking Spaces'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.car_rental),
                label: Text('Vehicles'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Persons'), // Update label
              ),
            ],
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
                PersonView(), // Update to use PersonView
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoute(int index) {
    switch (index) {
      case 0:
        return '/start';
      case 1:
        return '/statistics';
      case 2:
        return '/parkings';
      case 3:
        return '/parking-spaces';
      case 4:
        return '/vehicles';
      case 5:
        return '/persons';
      default:
        return '/start';
    }
  }
}
