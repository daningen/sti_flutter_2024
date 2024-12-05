// ignore_for_file: use_build_context_synchronously

import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
 
import 'package:shared/shared.dart'; // Import the Person model

class UserPage extends StatelessWidget {
  final PersonRepository _personRepository =
      PersonRepository();

  UserPage({super.key}); // Instantiate repository

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: FutureBuilder<List<Person>>(
        future: _personRepository.getAll(), // Call the getAll() method
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Show loading spinner
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          // If data is fetched successfully, display the list
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final person = users[index];
              return ListTile(
                title: Text(person.name), // Display name
                subtitle: Text('SSN: ${person.ssn}'), // Display SSN
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    // Add logic to delete user if needed
                    await _personRepository.delete(person.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User deleted')));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/'); // Navigate back to the start page
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}
