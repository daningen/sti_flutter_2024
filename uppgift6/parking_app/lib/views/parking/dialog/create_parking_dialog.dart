import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared/bloc/parkings/parking_bloc.dart';
import 'package:shared/bloc/parkings/parking_state.dart';
import 'package:shared/shared.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

//current create

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
    debugPrint("Entering _filterAvailableItems");

    final currentState = context.read<ParkingBloc>().state;
    debugPrint("Current State: ${currentState.runtimeType}");

    if (currentState is ParkingLoaded) {
      final loadedState = currentState;
      final nowUtc =
          DateTime.now().toUtc(); // Current time in UTC (only get it ONCE)

      debugPrint("Filtering Available Items:");
      debugPrint("Total Vehicles: ${widget.availableVehicles.length}");
      debugPrint(
          "Total Parking Spaces: ${widget.availableParkingSpaces.length}");
      debugPrint(
          "All Parkings: ${loadedState.allParkings.length}"); // Log allParkings

      _filteredAvailableVehicles = widget.availableVehicles.where((vehicle) {
        final isAvailable = !loadedState.allParkings.any((parking) {
          // Use allParkings
          return parking.vehicle?.id == vehicle.id &&
              (parking.endTime == null ||
                  parking.endTime!.toUtc().isAfter(nowUtc));
        });

        debugPrint("Vehicle ${vehicle.licensePlate}: Available = $isAvailable "
            "(endTime: ${loadedState.allParkings.firstWhere(
                  // Use allParkings here too
                  (p) => p.vehicle?.id == vehicle.id,
                  orElse: () => Parking(
                    startTime: DateTime.now(),
                    endTime: null,
                    vehicle: vehicle,
                    parkingSpace:
                        ParkingSpace(address: '', pricePerHour: 0, id: ''),
                  ),
                ).endTime?.toUtc()}, "
            "nowUtc: $nowUtc)");

        return isAvailable;
      }).toList();

      _filteredAvailableParkingSpaces =
          widget.availableParkingSpaces.where((space) {
        final isAvailable = !loadedState.allParkings.any((parking) {
          // Use allParkings
          return parking.parkingSpace?.id == space.id &&
              (parking.endTime == null ||
                  parking.endTime!.toUtc().isAfter(nowUtc));
        });

        debugPrint("Parking Space ${space.address}: Available = $isAvailable "
            "(endTime: ${loadedState.allParkings.firstWhere(
                  // And here
                  (p) => p.parkingSpace?.id == space.id,
                  orElse: () => Parking(
                    startTime: DateTime.now(),
                    endTime: null,
                    vehicle: Vehicle(
                        owner: Person(name: '', id: '', authId: '', ssn: ''),
                        licensePlate: '',
                        vehicleType: ''),
                    parkingSpace: space,
                  ),
                ).endTime?.toUtc()}, "
            "nowUtc: $nowUtc)");

        return isAvailable;
      }).toList();

      debugPrint("Filtered Vehicles: ${_filteredAvailableVehicles.length}");
      debugPrint(
          "Filtered Parking Spaces: ${_filteredAvailableParkingSpaces.length}");
      debugPrint(
          "Filtered Vehicles (License Plates): ${_filteredAvailableVehicles.map((v) => v.licensePlate).join(", ")}");
      debugPrint(
          "Filtered Parking Spaces (Addresses): ${_filteredAvailableParkingSpaces.map((s) => s.address).join(", ")}");
    } else {
      debugPrint(
          "Current State is NOT ParkingLoaded: ${currentState.runtimeType}");
    }
    debugPrint("Exiting _filterAvailableItems");
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
              
             DateTimeField(
  decoration: const InputDecoration(
    labelText: 'Estimated End Time (Optional)',
  ),
  format: DateFormat("yyyy-MM-ddTHH:mm:ss"),
  onShowPicker: (context, currentValue) async {
  DateTime? pickedDate = currentValue; // Initialize with current value
  TimeOfDay? pickedTime;
  DateTime? finalDateTime;

  final date = await showDatePicker(
    context: context,
    initialDate: currentValue ?? DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
  );

  if (date != null) {
    pickedDate = date; // Update pickedDate if date is selected

    // Initialize time based on currentValue only if same date is picked
    if (currentValue != null && currentValue.year == date.year && currentValue.month == date.month && currentValue.day == date.day) {
      pickedTime = TimeOfDay.fromDateTime(currentValue);
    }

    final time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: pickedTime ?? TimeOfDay.fromDateTime(
        currentValue ?? DateTime.now(),
      ),
    );

    if (time != null) {
      pickedTime = time;
      finalDateTime = DateTimeField.combine(pickedDate, pickedTime); // Combine date and time. Use pickedDate!
    } else {
      finalDateTime = pickedDate; // Only date selected. Use pickedDate
    }
  } else {
      finalDateTime = currentValue; // Use the initial value if date picker is cancelled.
  }

  estimatedEndTime = finalDateTime; // Set estimatedEndTime 
  return finalDateTime; // Return the final DateTime
},
  onChanged: (DateTime? value) {
    // Do NOTHING here.  This is essential.
  },
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
