import 'package:flutter/material.dart';
import 'package:shared/shared.dart'; // Ensure this contains your models

class EditParkingDialog extends StatefulWidget {
  final Parking parking;
  final List<ParkingSpace> availableParkingSpaces;
  final Function(Parking) onEdit;

  const EditParkingDialog({
    super.key,
    required this.parking,
    required this.availableParkingSpaces,
    required this.onEdit,
  });

  @override
  State<EditParkingDialog> createState() => _EditParkingDialogState();
}

class _EditParkingDialogState extends State<EditParkingDialog> {
  final formKey = GlobalKey<FormState>();
  ParkingSpace? selectedParkingSpace;

  @override
  void initState() {
    super.initState();
    // Preselect the current parking space
    selectedParkingSpace = widget.parking.parkingSpace;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Parking'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ParkingSpace>(
              decoration:
                  const InputDecoration(labelText: 'Select Parking Space'),
              value: selectedParkingSpace,
              items: widget.availableParkingSpaces.map((space) {
                return DropdownMenuItem<ParkingSpace>(
                  value: space,
                  child: Text(space.address),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedParkingSpace = value;
                });
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
              final updatedParking = widget.parking.copyWith(
                parkingSpace: selectedParkingSpace,
              );

              Navigator.of(context).pop();
              widget.onEdit(updatedParking);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
