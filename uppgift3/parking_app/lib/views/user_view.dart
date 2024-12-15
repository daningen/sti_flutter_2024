// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:parking_app/widgets/custom_bottom_nav_bar.dart';
import 'package:parking_app/providers/theme_notifier.dart';
import 'package:shared/shared.dart';
import 'package:parking_app/utils/validators.dart'; // Import the validators

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
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: Icon(
              themeNotifier.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              themeNotifier.toggleTheme();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Person>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final person = users[index];
              return ListTile(
                title: Text(person.name),
                subtitle: Text('SSN: ${person.ssn}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
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
                        _loadUsers();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentRoute: GoRouter.of(context).location,
      ),
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
                  validator: Validators.validateName, // Use external validator
                ),
                TextFormField(
                  controller: ssnController,
                  decoration: const InputDecoration(labelText: 'SSN'),
                  validator: Validators.validateSSN, // Use external validator
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
