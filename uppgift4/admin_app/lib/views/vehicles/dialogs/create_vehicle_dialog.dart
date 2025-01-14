import 'package:admin_app/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../../../utils/validators.dart';

class CreateVehicleDialog extends StatefulWidget {
  final Function(Vehicle) onCreate;
  final Future<List<Person>> ownersFuture;

  const CreateVehicleDialog({
    required this.onCreate,
    required this.ownersFuture,
    super.key,
  });

  @override
  State<CreateVehicleDialog> createState() => _CreateVehicleDialogState();
}

class _CreateVehicleDialogState extends State<CreateVehicleDialog> {
  final formKey = GlobalKey<FormState>();
  final licensePlateController = TextEditingController();
  String? selectedVehicleType;
  Person? selectedOwner;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Person>>(
      future: widget.ownersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final persons = snapshot.data ?? [];

        return AlertDialog(
          title: const Text('Create New Vehicle'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: licensePlateController,
                  decoration: const InputDecoration(labelText: 'License Plate'),
                  validator: Validators.validateLicensePlate,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: vehicleTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) => selectedVehicleType = value,
                  validator: (value) =>
                      value == null ? 'Please select a vehicle type' : null,
                ),
                DropdownButtonFormField<Person>(
                  decoration: const InputDecoration(labelText: 'Owner'),
                  items: persons.map((person) {
                    return DropdownMenuItem<Person>(
                      value: person,
                      child: Text(person.name),
                    );
                  }).toList(),
                  onChanged: (person) => selectedOwner = person,
                  validator: (value) =>
                      value == null ? 'Please select an owner' : null,
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
                  final newVehicle = Vehicle(
                    licensePlate: licensePlateController.text,
                    vehicleType: selectedVehicleType!,
                  );
                  newVehicle.setOwner(selectedOwner!); // Ensure owner is set
                  Navigator.of(context).pop(newVehicle);
                  widget.onCreate(newVehicle);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
