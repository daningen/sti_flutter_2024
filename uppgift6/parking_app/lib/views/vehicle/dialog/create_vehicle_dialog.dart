import 'package:flutter/material.dart';
import 'package:parking_app/app_constants.dart';
import 'package:shared/shared.dart';
import '../../../utils/validators.dart';

class CreateVehicleDialog extends StatefulWidget {
  const CreateVehicleDialog({
    super.key,
    required this.owners,
    required this.userRole,
    required this.loggedInUserAuthId,
  });

  final Future<List<Person>> owners;
  final String userRole;
  final String loggedInUserAuthId;

  @override
  State<CreateVehicleDialog> createState() => _CreateVehicleDialogState();
}

class _CreateVehicleDialogState extends State<CreateVehicleDialog> {
  final formKey = GlobalKey<FormState>();
  final licensePlateController = TextEditingController();
  String? selectedVehicleType;
  Person? selectedOwner;
  String? selectedOwnerAuthId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Person>>(
      future: widget.owners,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error.toString()}"));
        }

        final allOwners = snapshot.data ?? [];

        // Filter owners based on user role
        final owners = widget.userRole == 'admin'
            ? allOwners // Admin sees all owners
            : allOwners.where((person) => person.authId == widget.loggedInUserAuthId).toList(); // User sees only themselves

        return _buildDialogContent(owners);
      },
    );
  }

  Widget _buildDialogContent(List<Person> persons) {
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
              value: selectedVehicleType,
              items: vehicleTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedVehicleType = value;
                });
              },
              validator: (value) => value == null ? 'Please select a vehicle type' : null,
            ),
            DropdownButtonFormField<Person>(
              decoration: const InputDecoration(labelText: 'Owner'),
              value: selectedOwner,
              items: persons.map((person) => DropdownMenuItem<Person>(
                    value: person,
                    child: Text(person.name),
                  )).toList(),
              onChanged: (Person? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedOwner = newValue;
                    selectedOwnerAuthId = newValue.authId;
                  });
                }
              },
              validator: (value) => value == null ? 'Please select an owner' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Close the dialog
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              if (selectedOwnerAuthId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Owner is missing!')),
                );
                return;
              }

              final newVehicle = Vehicle(
                licensePlate: licensePlateController.text,
                vehicleType: selectedVehicleType!,
                authId: selectedOwnerAuthId!,
                ownerAuthId: selectedOwnerAuthId!,
              );

              Navigator.of(context).pop(newVehicle); // Return the new vehicle
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
