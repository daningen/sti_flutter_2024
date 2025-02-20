import 'package:flutter/material.dart';
import 'package:parking_app/app_constants.dart';
import 'package:shared/shared.dart';
import '../../../utils/validators.dart';

class CreateVehicleDialog extends StatefulWidget {
  final Future<List<Person>> ownersFuture;

  const CreateVehicleDialog({
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
  String? selectedOwnerAuthId; // Store the selected owner's authId

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
                  onChanged: (value) => setState(
                      () => selectedVehicleType = value), // Add setState
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
                  onChanged: (person) => setState(() {
                    // Add setState
                    selectedOwner = person;
                    selectedOwnerAuthId = person?.authId; // Store the authId
                  }),
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
                  if (selectedOwnerAuthId == null) {
                    // Only check ownerAuthId
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Owner is missing!')),
                    );
                    return;
                  }

                  final newVehicle = Vehicle(
                    licensePlate: licensePlateController.text,
                    vehicleType: selectedVehicleType!,
                    authId: selectedOwnerAuthId!, // Correct: Use ownerAuthId
                    ownerAuthId:
                        selectedOwnerAuthId!, // Correct: Use ownerAuthId
                  );

                  Navigator.of(context)
                      .pop(newVehicle); // Pop with the new Vehicle
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
