import 'package:flutter/material.dart';
import '../../../utils/validators.dart';
import 'package:shared/shared.dart';

class CreateParkingSpaceDialog extends StatelessWidget {
  final Function(ParkingSpace) onCreate;
  final List<ParkingSpace> availableParkingSpaces;

  const CreateParkingSpaceDialog({
    required this.onCreate,
    required this.availableParkingSpaces,
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
              DropdownButtonFormField<ParkingSpace>(
                decoration: const InputDecoration(labelText: 'Available Spaces'),
                items: availableParkingSpaces.map((space) {
                  return DropdownMenuItem(
                    value: space,
                    child: Text(space.address),
                  );
                }).toList(),
                onChanged: (space) {
                  if (space != null) {
                    addressController.text = space.address;
                  }
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: priceController,
                decoration:
                    const InputDecoration(labelText: 'Price (SEK/hr)'),
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
              try {
                final newParkingSpace = ParkingSpace(
                  address: addressController.text,
                  pricePerHour: int.parse(priceController.text),
                );
                Navigator.of(context).pop();
                onCreate(newParkingSpace);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid price format')),
                );
              }
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
