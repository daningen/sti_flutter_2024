// ignore_for_file: use_build_context_synchronously

import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart'; // Import the Person model
import 'custom_bottom_nav_bar.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
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
      ),
      body: FutureBuilder<List<Person>>(
        future: _usersFuture,
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
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  void _editUser(BuildContext context, Person person) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController =
        TextEditingController(text: person.name);
    final TextEditingController ssnController =
        TextEditingController(text: person.ssn);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    if (RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Name cannot contain numbers';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: ssnController,
                  decoration: const InputDecoration(labelText: 'SSN'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'SSN is required';
                    }
                    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                      return 'SSN must be in YYMMDD format';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Save updated data
                  person.name = nameController.text;
                  person.ssn = ssnController.text;
                  await _personRepository.update(person.id, person);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('User information updated successfully')));
                  _loadUsers();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
