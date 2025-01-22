import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class CreateParkingDialog extends StatelessWidget {
  final List<Vehicle> availableVehicles;
  final List<ParkingSpace> availableParkingSpaces;
  final Function(Parking) onCreate;

  const CreateParkingDialog({
    required this.availableVehicles,
    required this.availableParkingSpaces,
    required this.onCreate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    Vehicle? selectedVehicle;
    ParkingSpace? selectedParkingSpace;

    return AlertDialog(
      title: const Text('Create Parking'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Vehicle>(
              decoration: const InputDecoration(labelText: 'Select Vehicle'),
              items: availableVehicles
                  .map((vehicle) => DropdownMenuItem(
                        value: vehicle,
                        child: Text(vehicle.licensePlate),
                      ))
                  .toList(),
              onChanged: (value) {
                selectedVehicle = value;
              },
              validator: (value) =>
                  value == null ? 'Please select a vehicle' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ParkingSpace>(
              decoration: const InputDecoration(labelText: 'Select Parking Space'),
              items: availableParkingSpaces
                  .map((space) => DropdownMenuItem(
                        value: space,
                        child: Text(space.address),
                      ))
                  .toList(),
              onChanged: (value) {
                selectedParkingSpace = value;
              },
              validator: (value) =>
                  value == null ? 'Please select a parking space' : null,
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
              final newParking = Parking(
                id: '', // Ensure ID is handled properly
                startTime: DateTime.now(),
                vehicle: selectedVehicle,
                parkingSpace: selectedParkingSpace,
              );

              Navigator.of(context).pop();
              onCreate(newParking);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
