import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared/bloc/parkings/parking_bloc.dart';
import 'package:shared/bloc/parkings/parking_state.dart';
import 'package:shared/shared.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

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
  DateTime? estimatedEndTime;

  List<Vehicle> _filteredAvailableVehicles = []; // Store filtered vehicles
  List<ParkingSpace> _filteredAvailableParkingSpaces =
      []; // Store filtered spaces

  @override
  void initState() {
    super.initState();
    _filterAvailableItems(); // Initial filtering
  }

  void _filterAvailableItems() {
    // Access the current state of the ParkingBloc
    final currentState = context.read<ParkingBloc>().state;

    if (currentState is ParkingLoaded) {
      // Filter available vehicles
      _filteredAvailableVehicles = widget.availableVehicles.where((vehicle) {
        return !currentState.parkings.any((parking) =>
            parking.vehicle?.id == vehicle.id && parking.endTime == null);
      }).toList();

      // Filter available parking spaces
      _filteredAvailableParkingSpaces =
          widget.availableParkingSpaces.where((space) {
        return !currentState.parkings.any((parking) =>
            parking.parkingSpace?.id == space.id && parking.endTime == null);
      }).toList();
    }
  }

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
                items: _filteredAvailableVehicles.map((vehicle) {
                  // Use filtered list
                  // items: widget.availableVehicles.map((vehicle) {
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
                // items: widget.availableParkingSpaces.map((space) {
                items: _filteredAvailableParkingSpaces.map((space) {
                  // Use filtered list
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
              // Date/Time Picker for Estimated End Time
              DateTimeField(
                decoration: const InputDecoration(
                  labelText: 'Estimated End Time (Optional)',
                ),
                // format: DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSSS"), //
                format: DateFormat("yyyy-MM-ddTHH:mm:ss"), //
                onShowPicker: (context, currentValue) async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: currentValue ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      // ignore: use_build_context_synchronously
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        currentValue ?? DateTime.now(),
                      ),
                    );
                    return DateTimeField.combine(date, time);
                  } else {
                    debugPrint(
                        "[create_parking_dialog]: show it $currentValue");
                    return currentValue;
                  }
                },
                onChanged: (DateTime? value) {
                  debugPrint(
                      "Selected DateTime value: $value, Type: ${value.runtimeType}");
// todo can i remove this?
                  if (value != null) {
                    // Handle the case where the user selected a date/time
                    estimatedEndTime = DateTime(
                      value.year,
                      value.month,
                      value.day,
                      value.hour,
                      value.minute,
                      value.second,
                      // value.millisecond,
                      // value.microsecond,
                    ); // Create a new DateTime object

                    debugPrint(
                        "New estimatedEndTime value: $estimatedEndTime, Type: ${estimatedEndTime.runtimeType}");
                  } else {
                    // Handle null case appropriately
                    estimatedEndTime =
                        null; // Or some default DateTime if needed
                    debugPrint("estimatedEndTime set to null");
                  }
                },
                // onChanged: (DateTime? value) {
                //   debugPrint(
                //       "[create_parking_dialog:] Selected DateTime value: $value, Type: ${value.runtimeType}");
                //   setState(() {
                //     estimatedEndTime = value;
                //   });
                // },
                // You can add a validator if you want to make it required
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
            debugPrint(
                "[create_parking_Dialog:] endtime is {$estimatedEndTime}");
            debugPrint(
                "[create_parking_Dialog:] endtime type is: ${estimatedEndTime.runtimeType}");
            if (formKey.currentState!.validate()) {
              // Create a new Parking instance with selected values
              final newParking = Parking(
                startTime: DateTime.now(),
                endTime: estimatedEndTime,
                vehicle: selectedVehicle,
                parkingSpace: selectedParkingSpace,
              );

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
