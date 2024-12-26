import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart'; // Import your ThemeNotifier

class StartView extends StatelessWidget {
  const StartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Add AppBar
        title: const Text('Start'), // Optional title for the AppBar
        actions: [
          // Add actions for the toggle button
          IconButton(
            icon: Icon(
              Provider.of<ThemeNotifier>(context).themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Parking Admin App',
              // ignore: unnecessary_const
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.pushNamed(context, '/dashboard');
            //   },
            //   child: const Text('Start'),
            // ),
          ],
        ),
      ),
    );
  }
}
