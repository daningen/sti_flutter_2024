import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class EditParkingDialog extends StatelessWidget {
  final Parking parking;
  final List<ParkingSpace> availableParkingSpaces;
  final Function(Parking) onEdit;

  const EditParkingDialog({
    required this.parking,
    required this.availableParkingSpaces,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Validate selected parking space ID
    String? selectedParkingSpaceId = availableParkingSpaces
            .any((space) => space.id.toString() == parking.parkingSpace.target?.id.toString())
        ? parking.parkingSpace.target?.id.toString()
        : null;

    if (availableParkingSpaces.isEmpty) {
      return AlertDialog(
        title: const Text('Edit Parking'),
        content: const Text('No available parking spaces to select.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Edit Parking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedParkingSpaceId,
                decoration: const InputDecoration(labelText: 'Select Parking Space'),
                items: availableParkingSpaces
                    .map((space) => DropdownMenuItem(
                          value: space.id.toString(),
                          child: Text(space.address),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedParkingSpaceId = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedParkingSpaceId != null) {
                  final selectedSpace = availableParkingSpaces.firstWhere(
                    (space) => space.id.toString() == selectedParkingSpaceId,
                  );
                  final updatedParking = Parking(
                    id: parking.id,
                    startTime: parking.startTime,
                    endTime: parking.endTime,
                  );
                  updatedParking.setDetails(parking.vehicle.target!, selectedSpace);
                  onEdit(updatedParking);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a parking space')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
