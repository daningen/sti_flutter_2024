import 'package:flutter/material.dart';
import '../../../utils/validators.dart';


class CreateParkingSpaceDialog extends StatelessWidget {
  final Function(String, int) onCreate;

  const CreateParkingSpaceDialog({
    required this.onCreate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final addressController = TextEditingController();
    final priceController = TextEditingController();

    return AlertDialog(
      title: const Text('Create New Parking Space'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: Validators.validateAddress,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price (SEK/hr)'),
                keyboardType: TextInputType.number,
                validator: Validators.validatePrice,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            addressController.clear();
            priceController.clear();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              onCreate(
                addressController.text,
                int.parse(priceController.text),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}