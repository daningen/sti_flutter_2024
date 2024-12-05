import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_service.dart';

class LogoutView extends StatelessWidget {
  const LogoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logout'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Are you sure you want to logout?',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<AuthService>().logout(),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
