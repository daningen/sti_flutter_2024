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
    final licensePlateController = TextEditingController(text: vehicle.licensePlate);
    String? selectedVehicleType = vehicle.vehicleType;
    Person? selectedOwner = vehicle.owner.target;

    return AlertDialog(
      title: const Text('Edit Vehicle'),
      content: FutureBuilder<List<Person>>(
        future: ownersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final owners = snapshot.data ?? [];
          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                DropdownButtonFormField<String>(
                  value: selectedVehicleType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: vehicleTypes
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => selectedVehicleType = value,
                ),
                DropdownButtonFormField<Person>(
                  value: selectedOwner,
                  decoration: const InputDecoration(labelText: 'Owner'),
                  items: owners.map((person) {
                    return DropdownMenuItem(
                      value: person,
                      child: Text(person.name),
                    );
                  }).toList(),
                  onChanged: (person) => selectedOwner = person,
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              vehicle.licensePlate = licensePlateController.text;
              vehicle.vehicleType = selectedVehicleType!;
              vehicle.setOwner(selectedOwner!);

              Navigator.of(context).pop();
              onEdit(vehicle);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
