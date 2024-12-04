import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ParkingPage extends StatelessWidget {
  const ParkingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parking')),
      body: const Center(child: Text('Parking View')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/'); // Navigate back to the start page
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}
