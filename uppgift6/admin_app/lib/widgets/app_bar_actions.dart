import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Ensure you have this import for AuthFirebaseBloc
import '../theme_notifier.dart'; // Update the path based on your project structure
import 'package:shared/bloc/auth/auth_firebase_bloc.dart';


class AppBarActions extends StatelessWidget {
  const AppBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Theme Toggle Button
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
        // Logout Button
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            // Access AuthFirebaseBloc and trigger LogoutRequested event
            context.read<AuthFirebaseBloc>().add(LogoutRequested());
          },
          tooltip: 'Logout',
        ),
      ],
    );
  }
}
