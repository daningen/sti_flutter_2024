import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_app/views/person/dialog/create_person_dialog.dart';
import 'package:parking_app/views/person/person_navigation_bar.dart';
import 'package:parking_app/providers/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'package:shared/bloc/person/person_bloc.dart';
import 'package:shared/bloc/person/person_event.dart';
import 'package:shared/bloc/person/person_state.dart';

class PersonView extends StatelessWidget {
  const PersonView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Persons'),
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
      body: BlocBuilder<PersonBloc, PersonState>(
        builder: (context, state) {
          if (state is PersonLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PersonError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is PersonLoaded) {
            if (state.persons.isEmpty) {
              return const Center(child: Text('No persons found'));
            }

            final persons = state.persons;
            return ListView.builder(
              itemCount: persons.length,
              itemBuilder: (context, index) {
                final person = persons[index];
                return ListTile(
                  title: Text(person.name),
                  subtitle: Text('SSN: ${person.ssn}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editPerson(context, person);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          context
                              .read<PersonBloc>()
                              .add(DeletePerson(id: person.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Person deleted')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Unexpected state'));
          }
        },
      ),
      bottomNavigationBar: PersonNavigationBar(
        onHomePressed: () {
          context.go('/'); // Navigate to home
        },
        onReloadPressed: () {
          context.read<PersonBloc>().add(ReloadPersons());
        },
        onAddPersonPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => CreatePersonDialog(
              onCreate: (name, ssn) {
                context
                    .read<PersonBloc>()
                    .add(CreatePerson(name: name, ssn: ssn));
              },
            ),
          );
        },
        onLogoutPressed: () {
          context.go('/login');
        },
      ),
    );
  }

  void _editPerson(BuildContext context, Person person) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController =
        TextEditingController(text: person.name);
    final TextEditingController ssnController =
        TextEditingController(text: person.ssn);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Person'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Name cannot be empty'
                      : null,
                ),
                TextFormField(
                  controller: ssnController,
                  decoration: const InputDecoration(labelText: 'SSN'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'SSN cannot be empty'
                      : null,
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
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<PersonBloc>().add(
                        UpdatePerson(
                          id: person.id,
                          name: nameController.text,
                          ssn: ssnController.text,
                        ),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Person updated successfully')),
                  );
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
