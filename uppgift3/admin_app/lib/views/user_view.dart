// ignore_for_file: use_build_context_synchronously

import 'package:admin_app/widgets/bottom_action_buttons.dart.dart';
import 'package:flutter/material.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  late Future<List<Person>> _usersFuture;
  Person? _selectedUser;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = PersonRepository().getAll();
      _selectedUser = null; // Clear selection on reload
    });
  }

  void _createUser() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final ssnController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New User'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Name is required'
                      : null,
                ),
                TextFormField(
                  controller: ssnController,
                  decoration: const InputDecoration(labelText: 'SSN (YYMMDD)'),
                  validator: (value) => RegExp(r'^\d{6}$').hasMatch(value ?? '')
                      ? null
                      : 'SSN must be in YYMMDD format',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newUser = Person(
                    name: nameController.text,
                    ssn: ssnController.text,
                  );
                  PersonRepository().create(newUser).then((_) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('User created successfully')),
                    );
                    _loadUsers();
                  });
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _editUser() {
    if (_selectedUser == null) return;

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: _selectedUser!.name);
    final ssnController = TextEditingController(text: _selectedUser!.ssn);

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
                  validator: (value) => value == null || value.isEmpty
                      ? 'Name is required'
                      : null,
                ),
                TextFormField(
                  controller: ssnController,
                  decoration: const InputDecoration(labelText: 'SSN (YYMMDD)'),
                  validator: (value) => RegExp(r'^\d{6}$').hasMatch(value ?? '')
                      ? null
                      : 'SSN must be in YYMMDD format',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _selectedUser!.name = nameController.text;
                  _selectedUser!.ssn = ssnController.text;
                  PersonRepository()
                      .update(_selectedUser!.id, _selectedUser!)
                      .then((_) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('User updated successfully')),
                    );
                    _loadUsers();
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser() {
    if (_selectedUser == null) return;

    PersonRepository().delete(_selectedUser!.id).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted User: ${_selectedUser!.name}')),
      );
      setState(() {
        _selectedUser = null;
      });
      _loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Person>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final users = snapshot.data ?? [];
                return SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                    showCheckboxColumn: false, // No checkboxes
                    columns: const [
                      DataColumn(label: Text('NAME')),
                      DataColumn(label: Text('PERSONAL NUMBER')),
                    ],
                    rows: users.map((user) {
                      final isSelected = user == _selectedUser;
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          setState(() {
                            _selectedUser = selected == true ? user : null;
                          });
                        },
                        color: WidgetStateProperty.resolveWith<Color?>(
                          (states) => isSelected ? Colors.blue[100] : null,
                        ),
                        cells: [
                          DataCell(Text(user.name)),
                          DataCell(Text(user.ssn)),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          BottomActionButtons(
            onNew: _createUser,
            onEdit: _editUser,
            onDelete: _deleteUser,
            onReload: _loadUsers,
          ),
        ],
      ),
    );
  }
}
