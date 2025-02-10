import 'package:admin_app/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class EditVehicleDialog extends StatelessWidget {
  final Vehicle vehicle;
  final Future<List<Person>> ownersFuture;
  final Function(Vehicle) onEdit;

  const EditVehicleDialog({
    required this.vehicle,
    required this.ownersFuture,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final licensePlateController =
        TextEditingController(text: vehicle.licensePlate);
    String? selectedVehicleType = vehicle.vehicleType;
    Person? selectedOwner = vehicle.owner;

    return AlertDialog(
      title: const Text('Edit Vehicle'),
      content: FutureBuilder<List<Person>>(
        future: ownersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint("Error fetching owners: ${snapshot.error}");
            return const Center(
              child: Text("Error loading owners."),
            );
          }

          final owners = snapshot.data ?? [];

          // Log the fetched owners
          debugPrint("Fetched owners for edit: $owners");

          if (owners.isEmpty) {
            return const Center(
              child: Text("No owners available to assign."),
            );
          }

          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // License plate input
                TextFormField(
                  controller: licensePlateController,
                  decoration: const InputDecoration(labelText: 'License Plate'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'License plate is required';
                    }
                    return null;
                  },
                ),

                // Vehicle type dropdown
                DropdownButtonFormField<String>(
                  value: selectedVehicleType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: vehicleTypes
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {
                    selectedVehicleType = value;
                    debugPrint("Selected vehicle type: $selectedVehicleType");
                  },
                ),

                // Owner dropdown
                DropdownButtonFormField<Person>(
                  value: selectedOwner,
                  decoration: const InputDecoration(labelText: 'Owner'),
                  items: owners.map((person) {
                    return DropdownMenuItem<Person>(
                      value: person,
                      child: Text('${person.name} (${person.ssn})'),
                    );
                  }).toList(),
                  onChanged: (person) {
                    selectedOwner = person;
                    debugPrint("Selected owner: ${selectedOwner?.name}");
                  },
                  validator: (value) =>
                      value == null ? 'Please select an owner' : null,
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),

        // Save button
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              // Create the updated vehicle
              final updatedVehicle = vehicle.copyWith(
                licensePlate: licensePlateController.text.trim(),
                vehicleType: selectedVehicleType,
                owner: selectedOwner, // Ensure the owner is updated
              );

              // Log the updated vehicle
              debugPrint("Updating vehicle: ${updatedVehicle.toJson()}");

              Navigator.of(context).pop();
              onEdit(updatedVehicle);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
