 import 'package:shared/bloc/auth/auth_firebase_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'start_view.dart';
import 'statistics_view.dart';
import 'parking/parking_view.dart';
import 'parking_spaces/parking_space_view.dart';
import 'vehicles/vehicles_view.dart';
import 'person/person_view.dart';

class NavRailView extends StatefulWidget {
  final int initialIndex;

  const NavRailView({required this.initialIndex, super.key});

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
    final isWideScreen = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthFirebaseBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWideScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });

                final routes = [
                  '/start',
                  '/start/statistics',
                  '/start/parkings',
                  '/start/parking-spaces',
                  '/start/vehicles',
                  '/start/persons',
                ];
                GoRouter.of(context).go(routes[index]);
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
                  icon: Icon(Icons.location_on),
                  label: Text('Parking Spaces'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.car_rental),
                  label: Text('Vehicles'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('Persons'),
                ),
              ],
            ),
          if (isWideScreen) const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                StartView(),
                StatisticsView(),
                ParkingView(),
                ParkingSpacesView(),
                VehiclesView(),
                PersonView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
