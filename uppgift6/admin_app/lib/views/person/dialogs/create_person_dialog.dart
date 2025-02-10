import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../../../utils/validators.dart';

class CreatePersonDialog extends StatelessWidget {
  final Function(Person) onCreate;

  const CreatePersonDialog({required this.onCreate, super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final ssnController = TextEditingController();

    return AlertDialog(
      title: const Text('Create New Person'),
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
              final newPerson = Person(
                name: nameController.text,
                ssn: ssnController.text,
              );
              Navigator.of(context).pop();
              onCreate(newPerson);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}


