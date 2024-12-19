import 'package:flutter/material.dart';

class StartView extends StatelessWidget {
  const StartView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Parking Admin App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     // Navigate to the main screen or dashboard
            //     Navigator.pushNamed(context,
            //         '/dashboard'); // Replace '/dashboard' with your actual route name
            //   },
            //   child: const Text('Start'),
            // ),
          ],
        ),
      ),
    );
  }
}
