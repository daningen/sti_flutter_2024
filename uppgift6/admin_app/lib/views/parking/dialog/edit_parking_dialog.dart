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

    // Check if the current parking space exists in the available spaces
    if (widget.availableParkingSpaces
        .any((space) => space.id == widget.parking.parkingSpace?.id)) {
      selectedParkingSpace = widget.parking.parkingSpace;
    } else {
      debugPrint(
          'Preselected parking space is invalid or not in availableParkingSpaces: ${widget.parking.parkingSpace?.toJson()}');
      selectedParkingSpace = null; // Reset to avoid invalid dropdown value
    }
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
                debugPrint('Dropdown Item: ${space.toJson()}');
                return DropdownMenuItem<ParkingSpace>(
                  value: space,
                  child:
                      Text('${space.address} (${space.pricePerHour} SEK/hr)'),
                );
              }).toList(),
              onChanged: (value) {
                debugPrint('Selected Parking Space: ${value?.toJson()}');
                setState(() {
                  selectedParkingSpace = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  debugPrint('Validation failed: No parking space selected.');
                  return 'Please select a parking space';
                }

                if (!widget.availableParkingSpaces.contains(value)) {
                  debugPrint(
                      'Validation failed: Selected parking space is not in the available list.');
                  return 'Invalid parking space selected';
                }
                return null;
              },
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
