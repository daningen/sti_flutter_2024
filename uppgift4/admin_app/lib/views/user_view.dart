// ignore_for_file: use_build_context_synchronously

import 'package:admin_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:provider/provider.dart';
import 'package:shared/bloc/auth/auth_bloc.dart';
import 'package:shared/bloc/auth/auth_event.dart';
import 'package:shared/shared.dart';
import '../theme_notifier.dart';
import '../widgets/bottom_action_buttons.dart';

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
    // Existing _createUser logic remains unchanged
  }

  void _editUser() {
    // Existing _editUser logic remains unchanged
  }

  void _deleteUser() {
    // Existing _deleteUser logic remains unchanged
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Dispatch LogoutRequested event to the AuthBloc
              context.read<AuthBloc>().add(LogoutRequested());
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Person>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                // Existing FutureBuilder logic remains unchanged
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final users = snapshot.data ?? [];
                return SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                      if (Theme.of(context).brightness == Brightness.dark) {
                        return AppColors.headingRowColor;
                      }
                      return null;
                    }),
                    showCheckboxColumn: false,
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
