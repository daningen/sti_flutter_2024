import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../theme_notifier.dart'; // Update the path based on your project structure

class AppBarActions extends StatelessWidget {
  const AppBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
        // IconButton(
        //   icon: const Icon(Icons.logout),
        //   onPressed: () {
        //     context.read<AuthBloc>().add(LogoutRequested());
        //   },
        //   tooltip: 'Logout pleeeaase',
        // ),
      ],
    );
  }
}
