import 'package:admin_app/bloc/auth/auth_firebase_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';
import 'start_view.dart';
import 'statistics_view.dart';
import 'parking/parking_view.dart';
import 'parking_spaces/parking_space_view.dart';
import 'vehicles/vehicles_view.dart';
import 'person/person_view.dart';

class NavRailView extends StatefulWidget {
  final GoRouter router; // Router instance passed for navigation.
  final int initialIndex; // Initial index for NavigationRail.
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
    _selectedIndex = widget.initialIndex; // Initialize with the passed index.
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
              widget.router.go('/login');
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
                  _selectedIndex = index; // Update the selected index.
                  widget.router.go(_getRoute(index)); // Navigate to the route.
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
              trailing: const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Icon(Icons.logout), // Logout icon at the bottom
              ),
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
      bottomNavigationBar: !isWideScreen
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                  widget.router.go(_getRoute(index));
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home),
                  label: 'Start',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart),
                  label: 'Statistics',
                ),
                NavigationDestination(
                  icon: Icon(Icons.local_parking),
                  label: 'Parkings',
                ),
                NavigationDestination(
                  icon: Icon(Icons.location_on),
                  label: 'Parking Spaces',
                ),
                NavigationDestination(
                  icon: Icon(Icons.car_rental),
                  label: 'Vehicles',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people),
                  label: 'Persons',
                ),
              ],
            )
          : null,
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
