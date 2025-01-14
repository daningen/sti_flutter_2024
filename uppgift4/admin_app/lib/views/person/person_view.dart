import 'package:admin_app/views/person/dialogs/create_person_dialog.dart';
import 'package:admin_app/views/person/dialogs/edit_person_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/person/person_bloc.dart';
import '../../bloc/person/person_event.dart';
import '../../bloc/person/person_state.dart';
import '../../widgets/bottom_action_buttons.dart';
import '../../app_theme.dart';

class PersonView extends StatelessWidget {
  const PersonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Person Management'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              // Add theme toggling logic if necessary
            },
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: BlocBuilder<PersonBloc, PersonState>(
        builder: (context, state) {
          if (state is PersonInitial) {
            return Center(
              child: ElevatedButton(
                onPressed: () => context.read<PersonBloc>().add(LoadPersons()),
                child: const Text("Load Persons"),
              ),
            );
          } else if (state is PersonLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PersonLoaded) {
            final persons = state.persons;
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                      (states) =>
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.headingRowColor
                              : Colors.grey[200],
                    ),
                    showCheckboxColumn: false,
                    columns: const [
                      DataColumn(label: Text('NAME')),
                      DataColumn(label: Text('PERSONAL NUMBER')),
                    ],
                    rows: persons.map((person) {
                      final isSelected = person == state.selectedPerson;
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          context.read<PersonBloc>().add(
                                SelectPerson(person: person),
                              );
                        },
                        color: WidgetStateProperty.resolveWith<Color?>(
                          (states) => isSelected ? Colors.blue[100] : null,
                        ),
                        cells: [
                          DataCell(Text(person.name)),
                          DataCell(Text(person.ssn)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          } else if (state is PersonError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      bottomNavigationBar: BottomActionButtons(
        onNew: () async {
          await showDialog(
            context: context,
            builder: (context) => CreatePersonDialog(
              onCreate: (newPerson) {
                context.read<PersonBloc>().add(
                      CreatePerson(
                        name: newPerson.name,
                        ssn: newPerson.ssn,
                      ),
                    );
              },
            ),
          );
        },
        onEdit: () async {
          final currentState = context.read<PersonBloc>().state;
          if (currentState is PersonLoaded &&
              currentState.selectedPerson != null) {
            final selectedPerson = currentState.selectedPerson!;
            await showDialog(
              context: context,
              builder: (context) {
                return EditPersonDialog(
                  person: selectedPerson,
                  onEdit: (updatedPerson) {
                    context.read<PersonBloc>().add(
                          UpdatePerson(
                            id: updatedPerson.id,
                            name: updatedPerson.name,
                            ssn: updatedPerson.ssn,
                          ),
                        );
                  },
                );
              },
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No person selected to edit')),
            );
          }
        },
        onDelete: () {
          final currentState = context.read<PersonBloc>().state;
          if (currentState is PersonLoaded &&
              currentState.selectedPerson != null) {
            final selectedPerson = currentState.selectedPerson!;

            // Show confirmation dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirm Deletion'),
                content: Text(
                    'Are you sure you want to delete ${selectedPerson.name}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<PersonBloc>()
                          .add(DeletePerson(id: selectedPerson.id));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${selectedPerson.name} has been deleted.',
                          ),
                        ),
                      );
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          } else {
            // No person selected
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No person selected to delete')),
            );
          }
        },
        onReload: () {
          context.read<PersonBloc>().add(ReloadPersons());
        },
      ),
    );
  }
}
