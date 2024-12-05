// ignore_for_file: use_build_context_synchronously

import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart'; // Import the Person model

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final PersonRepository _personRepository = PersonRepository();
  late Future<List<Person>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _personRepository.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers, // Reload data when the button is pressed
          ),
        ],
      ),
      body: FutureBuilder<List<Person>>(
        future: _usersFuture, // Use the stored Future here
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
                trailing: Wrap(
                  spacing: 12,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Add logic to edit user here
                        // e.g., opening an edit dialog
                        _editUser(context, person);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _personRepository.delete(person.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User deleted')));
                        _loadUsers(); // Reload users after deletion
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'home',
            onPressed: () {
              context.go('/'); // Navigate back to the start page
            },
            child: const Icon(Icons.home),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'reload',
            onPressed: _loadUsers, // Reload data when the button is pressed
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  void _editUser(BuildContext context, Person person) {
    final TextEditingController nameController =
        TextEditingController(text: person.name);
    final TextEditingController ssnController =
        TextEditingController(text: person.ssn);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: ssnController,
                decoration: const InputDecoration(labelText: 'SSN'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Save updated data
                person.name = nameController.text;
                person.ssn = ssnController.text;
                await _personRepository.update(person.id, person);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('User information updated successfully')));
                _loadUsers();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
