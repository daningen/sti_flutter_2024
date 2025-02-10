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
        // Log the state of the FutureBuilder
        debugPrint("FutureBuilder snapshot state: ${snapshot.connectionState}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Log when waiting for the future
          debugPrint("Fetching owners: Waiting for data...");
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // Log the error if any
          debugPrint("Error fetching owners: ${snapshot.error}");
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to fetch owners: ${snapshot.error}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        }

        // Extract persons from snapshot data
        final persons = snapshot.data ?? [];
        debugPrint("Fetched owners: $persons");

        // If no persons are fetched, show an appropriate message
        if (persons.isEmpty) {
          debugPrint("No owners found in the fetched data.");
          return AlertDialog(
            title: const Text('No Owners Available'),
            content:
                const Text('No owners found. Please create a person first.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        }

        return AlertDialog(
          title: const Text('Create New Vehicle'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // License plate input
                TextFormField(
                  controller: licensePlateController,
                  decoration: const InputDecoration(labelText: 'License Plate'),
                  validator: Validators.validateLicensePlate,
                ),
                const SizedBox(height: 16),

                // Vehicle type dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: vehicleTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedVehicleType = value);
                    // Log selected vehicle type
                    debugPrint("Selected vehicle type: $selectedVehicleType");
                  },
                  validator: (value) =>
                      value == null ? 'Please select a vehicle type' : null,
                ),
                const SizedBox(height: 16),

                // Owner dropdown
                DropdownButtonFormField<Person>(
                  decoration: const InputDecoration(labelText: 'Owner'),
                  items: persons.map((person) {
                    return DropdownMenuItem<Person>(
                      value: person,
                      child: Text(person.name),
                    );
                  }).toList(),
                  onChanged: (person) {
                    setState(() => selectedOwner = person);
                    // Log selected owner
                    debugPrint("Selected owner: ${selectedOwner?.name}");
                  },
                  validator: (value) =>
                      value == null ? 'Please select an owner' : null,
                ),
              ],
            ),
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                debugPrint("CreateVehicleDialog canceled.");
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),

            // Create button
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Create a new vehicle with the provided data
                  final newVehicle = Vehicle(
                    licensePlate: licensePlateController.text.trim(),
                    vehicleType: selectedVehicleType!,
                    owner: selectedOwner, // Assign the owner directly
                  );

                  // Log the created vehicle
                  debugPrint("Creating vehicle: ${newVehicle.toJson()}");

                  // Close the dialog and invoke the onCreate callback
                  Navigator.of(context).pop();
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
