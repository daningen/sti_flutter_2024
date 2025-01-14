import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../../../utils/validators.dart';
class EditPersonDialog extends StatelessWidget {
  final Person person;
  final Function(Person) onEdit;

  const EditPersonDialog({required this.person, required this.onEdit, super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: person.name);
    final ssnController = TextEditingController(text: person.ssn);

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
              validator: Validators.validateName,
            ),
            TextFormField(
              controller: ssnController,
              decoration: const InputDecoration(labelText: 'SSN'),
              validator: Validators.validateSSN,
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
              final updatedPerson = Person(
                id: person.id,
                name: nameController.text,
                ssn: ssnController.text,
              );
              Navigator.of(context).pop();
              onEdit(updatedPerson);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
