// ignore_for_file: prefer_const_constructors

import 'package:admin_app/views/start_view.dart';
import 'package:admin_app/views/statistics_view.dart';
import 'package:admin_app/views/user_view.dart'; // Renamed user_view2 to user_view
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';

// import 'views/items_view.dart';
import 'views/parking_space_view.dart';
import 'views/parking_view.dart';
import 'views/vehicles_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/start',
    routes: [
      GoRoute(
        path: '/start',
        builder: (context, state) => const NavRailView(index: 0),
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const NavRailView(index: 1),
      ),
      GoRoute(
        path: '/parkings',
        builder: (context, state) => const NavRailView(index: 2),
      ),
      GoRoute(
        path: '/parking-spaces',
        builder: (context, state) => const NavRailView(index: 3),
      ),
      GoRoute(
        path: '/vehicles',
        builder: (context, state) => const NavRailView(index: 4),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const NavRailView(index: 5),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp.router(
          title: 'Managing App',
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 206, 234, 250),
            ),
            // scaffoldBackgroundColor: const Color.fromARGB(255, 240, 80, 144),
          ),
          darkTheme: ThemeData.dark(),
          themeMode: themeNotifier.themeMode,
        );
      },
    );
  }
}

class NavRailView extends StatefulWidget {
  final int index;

  const NavRailView({required this.index, super.key});

  @override
  State<NavRailView> createState() => _NavRailViewState();
}

class _NavRailViewState extends State<NavRailView> {
  late int _selectedIndex;

  // Centralized color for selected icons
  final Color selectedIconColor = const Color.fromARGB(133, 246, 129, 135);

  final List<NavigationRailDestination> destinations = [
    const NavigationRailDestination(
      icon: Icon(Icons.home),
      selectedIcon: Icon(Icons.home),
      label: Text('Start'),
    ),
    // const NavigationRailDestination(
    //   icon: Icon(Icons.favorite_border),
    //   selectedIcon: Icon(Icons.favorite),
    //   label: Text('Items'),
    // ),
    const NavigationRailDestination(
      icon: Icon(Icons.bookmark_border),
      selectedIcon: Icon(Icons.book),
      label: Text('Statistics'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.car_repair_sharp),
      selectedIcon: Icon(Icons.car_repair_sharp),
      label: Text('Parkings'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.local_parking),
      selectedIcon: Icon(Icons.local_parking),
      label: Text('Parking Spaces'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.directions_car),
      selectedIcon: Icon(Icons.directions_car),
      label: Text('Vehicles'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.people),
      selectedIcon: Icon(Icons.people),
      label: Text('Users'),
    ),
  ];

  final List<Widget> views = [
    const StartView(),
    // const ItemsView(index: 0),
    const StatisticsView(),
    const ParkingView(),
    const ParkingSpacesView(),
    const VehiclesView(),
    const UserView(), // Updated UserView
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 193, 220, 238),
      body: Row(
        children: <Widget>[
          NavigationRail(
            backgroundColor: const Color.fromARGB(255, 234, 239, 243),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
                _navigateToRoute(context, index);
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: destinations.map((destination) {
              return NavigationRailDestination(
                icon: destination.icon,
                selectedIcon: Icon(
                  (destination.selectedIcon as Icon).icon,
                  color: selectedIconColor,
                ),
                label: destination.label,
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 200, 204, 207),
              child: views[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRoute(BuildContext context, int index) {
    final routes = [
      // '/items',
      '/start',
      '/statistics',
      '/parkings',
      '/parking-spaces',
      '/vehicles',
      '/users',
    ];
    if (index >= 0 && index < routes.length) {
      GoRouter.of(context).go(routes[index]);
    }
  }
}
