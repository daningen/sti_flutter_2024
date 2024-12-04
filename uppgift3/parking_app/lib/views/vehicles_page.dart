import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VehiclesPage extends StatelessWidget {
  const VehiclesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles Page'),
      ),
      body: const Center(child: Text('Vehicles Page View')),
      // Add the home button in the lower-right corner
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/'); // Navigate back to the start page
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}
