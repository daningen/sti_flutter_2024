import 'package:admin_app/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../../../utils/validators.dart';

class CreateVehicleDialog extends StatefulWidget {
  final Function(Vehicle) onCreate; // Callback function to be called when a vehicle is created
  final Future<List<Person>> ownersFuture; // Future that resolves to a list of Person objects

  const CreateVehicleDialog({
    required this.onCreate,
    required this.ownersFuture,
    super.key,
  });

  @override
  State<CreateVehicleDialog> createState() => _CreateVehicleDialogState();
}

class _CreateVehicleDialogState extends State<CreateVehicleDialog> {
  final formKey = GlobalKey<FormState>(); // Key for the form
  final licensePlateController = TextEditingController(); // Controller for the license plate text field
  String? selectedVehicleType; // Stores the selected vehicle type
  Person? selectedOwner; // Stores the selected owner (Person object)
  String? selectedOwnerAuthId; // Stores the selected owner's authId

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Person>>(
      future: widget.ownersFuture, // The future that resolves to the list of owners
      builder: (context, snapshot) {
        debugPrint("FutureBuilder snapshot state: ${snapshot.connectionState}"); // Log the connection state

        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint("Fetching owners: Waiting for data..."); // Log waiting message
          return const Center(child: CircularProgressIndicator()); // Show a loading indicator
        }

        if (snapshot.hasError) {
          debugPrint("Error fetching owners: ${snapshot.error}"); // Log the error
          return AlertDialog( // Show an error dialog
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

        final persons = snapshot.data ?? []; // Extract the list of Person objects from the snapshot
        debugPrint("Fetched owners: $persons"); // Log the fetched owners

        if (persons.isEmpty) {
          debugPrint("No owners found in the fetched data."); // Log if no owners are found
          return AlertDialog( // Show a dialog indicating no owners are available
            title: const Text('No Owners Available'),
            content: const Text('No owners found. Please create a person first.'),
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
            key: formKey, // Assign the form key
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField( // License plate input field
                  controller: licensePlateController,
                  decoration: const InputDecoration(labelText: 'License Plate'),
                  validator: Validators.validateLicensePlate, // Validate the license plate
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>( // Vehicle type dropdown
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: vehicleTypes.map((type) => DropdownMenuItem( // Create dropdown items
                        value: type,
                        child: Text(type),
                      )).toList(),
                  onChanged: (value) {
                    setState(() => selectedVehicleType = value); // Update selected vehicle type
                    debugPrint("Selected vehicle type: $selectedVehicleType"); // Log the selected type
                  },
                  validator: (value) => value == null ? 'Please select a vehicle type' : null, // Validate selection
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<Person>( // Owner dropdown
                  decoration: const InputDecoration(labelText: 'Owner'),
                  items: persons.map((person) { // Create dropdown items for owners
                    return DropdownMenuItem<Person>(
                      value: person,
                      child: Text(person.name),
                    );
                  }).toList(),
                  onChanged: (person) {
                    setState(() {
                      selectedOwner = person; // Update selected owner (Person object)
                      selectedOwnerAuthId = person?.authId; // Store the selected owner's authId
                    });
                    debugPrint("Selected owner: ${selectedOwner?.name}, authId: $selectedOwnerAuthId"); // Log the selected owner and authId
                  },
                  validator: (value) => value == null ? 'Please select an owner' : null, // Validate selection
                ),
              ],
            ),
          ),
          actions: [
            TextButton( // Cancel button
              onPressed: () {
                debugPrint("CreateVehicleDialog canceled."); // Log cancellation
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton( // Create button
              onPressed: () {
                if (formKey.currentState!.validate()) { // Validate the form
                  if (selectedOwnerAuthId == null) { // Check if authId is available
                    ScaffoldMessenger.of(context).showSnackBar( // Show a snackbar message
                      const SnackBar(content: Text('Owner AuthId is missing!')),
                    );
                    return; // Don't proceed with vehicle creation
                  }

                  final newVehicle = Vehicle( // Create the new Vehicle object
                    licensePlate: licensePlateController.text.trim(),
                    vehicleType: selectedVehicleType!,
                    authId: selectedOwnerAuthId!, ownerAuthId: '', // Use the stored authId
                    // owner: selectedOwner, // You can keep the Person object if needed.
                  );

                  debugPrint("Creating vehicle: ${newVehicle.toJson()}"); // Log the created vehicle

                  Navigator.of(context).pop(); // Close the dialog
                  widget.onCreate(newVehicle); // Call the onCreate callback
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