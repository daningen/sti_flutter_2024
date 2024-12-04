import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User')),
      body: const Center(child: Text('User View')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/'); // Navigate back to the start page
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}
