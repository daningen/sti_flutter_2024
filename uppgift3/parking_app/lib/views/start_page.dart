import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parking App')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => context.go('/user-page'),
            child: const Text('Create User'),
          ),
          ElevatedButton(
            onPressed: () => context.go('/my-vehicles'),
            child: const Text('My Vehicles'),
          ),
          ElevatedButton(
            onPressed: () => context.go('/parking-spaces'),
            child: const Text('Parking Spaces'),
          ),
          ElevatedButton(
            onPressed: () => context.go('/parking'),
            child: const Text('Parking'),
          ),
        ],
      ),
    );
  }
}
