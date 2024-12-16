import 'package:admin_app/widgets/bottom_action_buttons.dart.dart';
import 'package:flutter/material.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';

class UserView2 extends StatefulWidget {
  const UserView2({super.key});

  @override
  State<UserView2> createState() => _UserView2State();
}

class _UserView2State extends State<UserView2> {
  late Future<List<Person>> _usersFuture;
  Person? _selectedUser; // For highlighting the selected user

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create User Clicked')),
    );
  }

  void _editUser() {
    if (_selectedUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Edit User: ${_selectedUser!.name}')),
      );
    }
  }

  void _deleteUser() {
    if (_selectedUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted User: ${_selectedUser!.name}')),
      );
      _selectedUser = null;
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        title: const Text('User Management'),
      ),
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
                    showCheckboxColumn:
                        false, // Disable checkboxes for all rows
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
