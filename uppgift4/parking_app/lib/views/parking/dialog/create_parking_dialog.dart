import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class CreateParkingDialog extends StatefulWidget {
  final List<Vehicle> availableVehicles;
  final List<ParkingSpace> availableParkingSpaces;
  final Function(Parking) onCreate;

  const CreateParkingDialog({
    super.key,
    required this.onCreate,
    required this.availableVehicles,
    required this.availableParkingSpaces,
  });

  @override
  State<CreateParkingDialog> createState() => _CreateParkingDialogState();
}

class _CreateParkingDialogState extends State<CreateParkingDialog> {
  final formKey = GlobalKey<FormState>();
  Vehicle? selectedVehicle;
  ParkingSpace? selectedParkingSpace;

  @override
  Widget build(BuildContext context) {
    debugPrint('CreateParkingDialog build called with:');
    debugPrint('- Available Vehicles: ${widget.availableVehicles.length}');
    debugPrint(
        '- Available Parking Spaces: ${widget.availableParkingSpaces.length}');

    return AlertDialog(
      title: const Text('Create Parking'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown for selecting a vehicle
              DropdownButtonFormField<Vehicle>(
                decoration: const InputDecoration(labelText: 'Select Vehicle'),
                items: widget.availableVehicles.map((vehicle) {
                  debugPrint(
                      'Adding Vehicle to Dropdown: ${vehicle.licensePlate}');
                  return DropdownMenuItem<Vehicle>(
                    value: vehicle,
                    child: Text(vehicle.licensePlate),
                  );
                }).toList(),
                onChanged: (vehicle) {
                  debugPrint('Selected Vehicle: ${vehicle?.licensePlate}');
                  setState(() {
                    selectedVehicle = vehicle;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a vehicle' : null,
              ),

              const SizedBox(height: 16),

              // Dropdown for selecting a parking space
              DropdownButtonFormField<ParkingSpace>(
                decoration:
                    const InputDecoration(labelText: 'Select Parking Space'),
                items: widget.availableParkingSpaces.map((space) {
                  debugPrint(
                      'Adding Parking Space to Dropdown: ${space.address}');
                  return DropdownMenuItem<ParkingSpace>(
                    value: space,
                    child: Text(space.address),
                  );
                }).toList(),
                onChanged: (space) {
                  debugPrint('Selected Parking Space: ${space?.address}');
                  setState(() {
                    selectedParkingSpace = space;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a parking space' : null,
              ),
            ],
          ),
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
              // Explicitly set details instead of using the cascade operator
              final newParking = Parking(startTime: DateTime.now());
              newParking.vehicle.target = selectedVehicle;
              newParking.parkingSpace.target = selectedParkingSpace;

              Navigator.of(context).pop();
              widget.onCreate(newParking);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
