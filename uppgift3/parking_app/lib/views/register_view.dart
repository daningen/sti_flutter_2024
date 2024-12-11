// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  if (RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Name should not contain numbers';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ssnController,
                decoration: const InputDecoration(labelText: 'SSN (yymmdd)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an SSN';
                  }
                  if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                    return 'SSN must be in the format yymmdd';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final name = _nameController.text;
                    final ssn = _ssnController.text;

                    try {
                      // Check if the user already exists
                      final userExists = await _personRepository.getAll().then(
                          (users) => users.any(
                              (user) => user.name == name && user.ssn == ssn));

                      if (userExists) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'User with this name and SSN already exists')),
                        );
                        return;
                      }

                      // Create the user in the Person repository
                      final person = Person(name: name, ssn: ssn);
                      await _personRepository.create(person);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account created successfully'),
                        ),
                      );

                      context.go('/login');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create account: $e')),
                      );
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
