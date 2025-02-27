import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared/bloc/parkings/parking_bloc.dart';
import 'package:shared/bloc/parkings/parking_state.dart';
import 'package:shared/shared.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:uuid/uuid.dart';

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
  final uuid = const Uuid(); // Create uuid instance here

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

    // 1. Get the current ParkingBloc state.
    final parkingState = context.read<ParkingBloc>().state;
    debugPrint("Current Parking State: ${parkingState.runtimeType}");

    // 2. Check if the ParkingBloc state is ParkingLoaded.  We only proceed
    //    with filtering if the parking data has been loaded.
    if (parkingState is ParkingLoaded) {
      final loadedParkingState = parkingState;

     
      final nowUtc = DateTime.now().toUtc();

      debugPrint("Filtering Available Items:");
      debugPrint("Total Vehicles: ${widget.availableVehicles.length}");
      debugPrint(
          "Total Parking Spaces: ${widget.availableParkingSpaces.length}");
      debugPrint(
          "All Parkings: ${loadedParkingState.allParkings.length}"); // Log all parkings

     
      _filteredAvailableVehicles = widget.availableVehicles.where((vehicle) {
        // Check if the vehicle is currently parked (unavailable).
        final isAvailable = !loadedParkingState.allParkings.any((parking) {
          // A vehicle is considered unavailable if it's already in a parking
          // and the parking has not ended or has an end time in the future.
          return parking.vehicle?.id == vehicle.id &&
              (parking.endTime == null ||
                  parking.endTime!.toUtc().isAfter(nowUtc));
        });

        // 4b. Debug print to check availability.
        debugPrint("Vehicle ${vehicle.licensePlate}: Available = $isAvailable "
            "(endTime: ${loadedParkingState.allParkings.firstWhere(
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

        // 4c. Return true if the vehicle is available, false otherwise.
        return isAvailable;
      }).toList(); // 5. Convert the filtered iterable to a list.

      // 6. Filter the available parking spaces. The logic is the same as for vehicles.
      _filteredAvailableParkingSpaces =
          widget.availableParkingSpaces.where((space) {
        final isAvailable = !loadedParkingState.allParkings.any((parking) {
          return parking.parkingSpace?.id == space.id &&
              (parking.endTime == null ||
                  parking.endTime!.toUtc().isAfter(nowUtc));
        });

        debugPrint("Parking Space ${space.address}: Available = $isAvailable "
            "(endTime: ${loadedParkingState.allParkings.firstWhere(
                  (p) => p.parkingSpace?.id == space.id,
                  orElse: () => Parking(
                    startTime: DateTime.now(),
                    endTime: null,
                    vehicle: Vehicle(
                      ownerAuthId: '',
                      licensePlate: '',
                      vehicleType: '',
                      authId: '',
                    ),
                    parkingSpace: space,
                  ),
                ).endTime?.toUtc()}, "
            "nowUtc: $nowUtc)");

        return isAvailable; // Return true if the parking space is available.
      }).toList(); // 7. Convert the filtered iterable to a list.

      // 8. Debug print the filtered lists.
      debugPrint("Filtered Vehicles: ${_filteredAvailableVehicles.length}");
      debugPrint(
          "Filtered Parking Spaces: ${_filteredAvailableParkingSpaces.length}");
      debugPrint(
          "Filtered Vehicles (License Plates): ${_filteredAvailableVehicles.map((v) => v.licensePlate).join(", ")}");
      debugPrint(
          "Filtered Parking Spaces (Addresses): ${_filteredAvailableParkingSpaces.map((s) => s.address).join(", ")}");
    } else {
      // 9. Log if the ParkingBloc state is not ParkingLoaded.
      debugPrint(
          "Current Parking State is NOT ParkingLoaded: ${parkingState.runtimeType}");
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
                  DateTime? pickedDate =
                      currentValue; // Initialize with current value
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
                    if (currentValue != null &&
                        currentValue.year == date.year &&
                        currentValue.month == date.month &&
                        currentValue.day == date.day) {
                      pickedTime = TimeOfDay.fromDateTime(currentValue);
                    }

                    final time = await showTimePicker(
                      // ignore: use_build_context_synchronously
                      context: context,
                      initialTime: pickedTime ??
                          TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now(),
                          ),
                    );

                    if (time != null) {
                      pickedTime = time;
                      finalDateTime = DateTimeField.combine(pickedDate,
                          pickedTime); // Combine date and time. Use pickedDate!
                    } else {
                      finalDateTime =
                          pickedDate; // Only date selected. Use pickedDate
                    }
                  } else {
                    finalDateTime =
                        currentValue; // Use the initial value if date picker is cancelled.
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
              final notificationId = uuid.v4().hashCode;
              // Create a new Parking instance with selected values
              final newParking = Parking(
                startTime: DateTime.now(),
                endTime: estimatedEndTime,
                vehicle: selectedVehicle,
                parkingSpace: selectedParkingSpace,
                notificationId: notificationId,
              );
              debugPrint(
                  "Parking object created with notificationId: $newParking"); // Debug print
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
