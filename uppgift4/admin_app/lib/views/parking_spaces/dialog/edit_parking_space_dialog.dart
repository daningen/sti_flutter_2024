import 'package:flutter/material.dart';
import '../../../utils/validators.dart';
import 'package:shared/shared.dart';

class EditParkingSpaceDialog extends StatelessWidget {
  final ParkingSpace parkingSpace;
  final Function(ParkingSpace) onEdit;

  const EditParkingSpaceDialog({
    required this.parkingSpace,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final addressController = TextEditingController(text: parkingSpace.address);
    final priceController = TextEditingController(
        text: parkingSpace.pricePerHour.toString());

    return AlertDialog(
      title: const Text('Edit Parking Space'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              validator: Validators.validateAddress,
            ),
            TextFormField(
              controller: priceController,
              decoration:
                  const InputDecoration(labelText: 'Price (SEK/hr)'),
              keyboardType: TextInputType.number,
              validator: Validators.validatePrice,
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
              final updatedParkingSpace = ParkingSpace(
                id: parkingSpace.id,
                address: addressController.text,
                pricePerHour: int.parse(priceController.text),
              );
              Navigator.of(context).pop();
              onEdit(updatedParkingSpace);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
