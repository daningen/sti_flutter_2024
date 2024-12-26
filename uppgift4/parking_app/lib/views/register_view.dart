// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_app/utils/validators.dart';
import 'package:shared/shared.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ssnController = TextEditingController();
  final PersonRepository _personRepository = PersonRepository();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ssnController,
                decoration: const InputDecoration(labelText: 'SSN (yymmdd)'),
                validator: Validators.validateSSN,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);

                          final name = _nameController.text.trim();
                          final ssn = _ssnController.text.trim();

                          // Check if the user already exists
                          final existingUsers =
                              await _personRepository.getAll();
                          final userExists = existingUsers.any((person) =>
                              person.name == name && person.ssn == ssn);

                          if (userExists) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('User already exists'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            setState(() => _isLoading = false);
                            return;
                          }

                          try {
                            // Create the new user
                            final person = Person(name: name, ssn: ssn);
                            await _personRepository.create(person);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Account created successfully'),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            _nameController.clear();
                            _ssnController.clear();
                            context.go('/login'); // Redirect to login
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to create account: $e'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
                      child: const Text('Create Account'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
