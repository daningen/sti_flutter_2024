import 'package:flutter/material.dart';
import 'package:parking_app/utils/validators.dart';

class CreatePersonDialog extends StatelessWidget {
  final Function(String name, String ssn) onCreate;

  const CreatePersonDialog({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ssnController = TextEditingController();

    return AlertDialog(
      title: const Text('Create Person'),
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
              onCreate(nameController.text, ssnController.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
