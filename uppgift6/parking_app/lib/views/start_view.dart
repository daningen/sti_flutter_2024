import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc package for state management
import 'package:shared/bloc/auth/auth_firebase_bloc.dart'; // Import your Auth BLoC
import 'package:shared/shared.dart'; // Import your shared models (including Person)

class StartView extends StatelessWidget {
  const StartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center( // Center the content on the screen
        child: Column( // Arrange children vertically
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          children: [
            const Text( // Welcome text
              'Welcome to the Parking Admin App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20), // Add some spacing

            // Display logged-in user information using BlocBuilder
            BlocBuilder<AuthFirebaseBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) { // Check if user is authenticated
                  final Person loggedInUser = state.person; // Access logged-in user

                  return Column(
                    children: [
                      Text(  
                        'User logged in: ${loggedInUser.name}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(  
                        'Role: ${loggedInUser.role}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  );
                } else {
                  return const Text(  
                    'User not logged in.',  
                    style: TextStyle(fontSize: 16),
                  );
                }
              },
            ),

          ],
        ),
      ),
    );
  }
}