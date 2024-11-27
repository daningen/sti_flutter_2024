import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: 0,
              onDestinationSelected: (int index) {},
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  selectedIcon: Icon(Icons.home, color: Colors.purple),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  selectedIcon: Icon(Icons.people, color: Colors.purple),
                  label: Text('Users'),
                ),
              ],
            ),
            const Expanded(
              child: Center(
                child: Text('Content Area'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
