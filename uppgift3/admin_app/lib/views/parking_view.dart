// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';
import 'package:intl/intl.dart';
import '../theme_notifier.dart';

// import '../widgets/bottom_action_buttons.dart.dart';

class ParkingView extends StatefulWidget {
  const ParkingView({super.key});

  @override
  State<ParkingView> createState() => _ParkingViewState();
}

class _ParkingViewState extends State<ParkingView> {
  late Future<List<Parking>> _parkingsFuture;
  Parking? _selectedParking;
  bool _showActiveOnly = false;

  final DateFormat timeFormat =
      DateFormat('yyyy-MM-dd HH:mm'); // Format to minutes

  @override
  void initState() {
    super.initState();
    _loadParkings();
  }

  void _loadParkings() {
    setState(() {
      _parkingsFuture = ParkingRepository().getAll().then((parkings) {
        return _showActiveOnly
            ? parkings.where((p) => p.endTime == null).toList()
            : parkings;
      });
      _selectedParking = null;
    });
  }

  // void _createParking() {
  //   final formKey = GlobalKey<FormState>();
  //   Person? selectedOwner;
  //   Vehicle? selectedVehicle;
  //   ParkingSpace? selectedParkingSpace;

  //   // Load necessary data
  //   Future.wait([
  //     PersonRepository().getAll(),
  //     ParkingSpaceRepository().getAll(),
  //     ParkingRepository().getAll(),
  //   ]).then((results) {
  //     final allOwners = results[0] as List<Person>;
  //     final allSpaces = results[1] as List<ParkingSpace>;
  //     final allParkings = results[2] as List<Parking>;

  //     // Filter owners: must have at least one vehicle
  //     final ownersWithVehicles = allOwners.where((owner) {
  //       return owner.vehicles.isNotEmpty; // Assumes 'vehicles' exists
  //     }).toList();

  //     showDialog(
  //       context: context,
  //       builder: (context) {
  //         List<Vehicle> availableVehicles = [];

  //         return StatefulBuilder(
  //           builder: (context, setState) {
  //             return AlertDialog(
  //               title: const Text('Create New Parking'),
  //               content: Form(
  //                 key: formKey,
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     // Owner Dropdown
  //                     DropdownButtonFormField<Person>(
  //                       decoration:
  //                           const InputDecoration(labelText: 'Select Owner'),
  //                       items: ownersWithVehicles.map((owner) {
  //                         return DropdownMenuItem<Person>(
  //                           value: owner,
  //                           child: Text(owner.name),
  //                         );
  //                       }).toList(),
  //                       onChanged: (owner) {
  //                         setState(() {
  //                           selectedOwner = owner;

  //                           // Update vehicles for selected owner
  //                           availableVehicles =
  //                               owner!.vehicles.where((vehicle) {
  //                             final hasOngoingParking = allParkings.any(
  //                                 (parking) =>
  //                                     parking.vehicle.target?.id ==
  //                                         vehicle.id &&
  //                                     parking.endTime == null);
  //                             return !hasOngoingParking; // Exclude vehicles with ongoing parking
  //                           }).toList();

  //                           selectedVehicle = null; // Reset vehicle selection
  //                         });
  //                       },
  //                       validator: (value) =>
  //                           value == null ? 'Select an owner' : null,
  //                     ),
  //                     const SizedBox(height: 12),

  //                     // Vehicle Dropdown (filtered based on selected owner)
  //                     DropdownButtonFormField<Vehicle>(
  //                       decoration:
  //                           const InputDecoration(labelText: 'Select Vehicle'),
  //                       items: availableVehicles.map((vehicle) {
  //                         return DropdownMenuItem<Vehicle>(
  //                           value: vehicle,
  //                           child: Text(vehicle.licensePlate),
  //                         );
  //                       }).toList(),
  //                       onChanged: (vehicle) => selectedVehicle = vehicle,
  //                       validator: (value) =>
  //                           value == null ? 'Select a vehicle' : null,
  //                     ),
  //                     const SizedBox(height: 12),

  //                     // Parking Space Dropdown
  //                     DropdownButtonFormField<ParkingSpace>(
  //                       decoration: const InputDecoration(
  //                           labelText: 'Select Parking Space'),
  //                       items: allSpaces.map((space) {
  //                         return DropdownMenuItem<ParkingSpace>(
  //                           value: space,
  //                           child: Text(space.address),
  //                         );
  //                       }).toList(),
  //                       onChanged: (space) => selectedParkingSpace = space,
  //                       validator: (value) =>
  //                           value == null ? 'Select a parking space' : null,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () => Navigator.of(context).pop(),
  //                   child: const Text('Cancel'),
  //                 ),
  //                 ElevatedButton(
  //                   onPressed: () {
  //                     if (formKey.currentState!.validate()) {
  //                       final newParking = Parking(startTime: DateTime.now());
  //                       newParking.setDetails(
  //                           selectedVehicle!, selectedParkingSpace!);

  //                       ParkingRepository().create(newParking).then((_) {
  //                         Navigator.of(context).pop();
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           const SnackBar(
  //                               content: Text('Parking created successfully')),
  //                         );
  //                         _loadParkings();
  //                       });
  //                     }
  //                   },
  //                   child: const Text('Create'),
  //                 ),
  //               ],
  //             );
  //           },
  //         );
  //       },
  //     );
  //   });
  // }

  // void _deleteParking() {
  //   if (_selectedParking == null) return;

  //   ParkingRepository().delete(_selectedParking!.id).then((_) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Parking deleted successfully')),
  //     );
  //     _loadParkings();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Management'),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeNotifier>(context).themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showActiveOnly = false;
                    _loadParkings();
                  });
                },
                child: const Text('All Parkings'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showActiveOnly = true;
                    _loadParkings();
                  });
                },
                child: const Text('Active Parkings'),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<Parking>>(
              future: _parkingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final parkings = snapshot.data ?? [];
                return SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                    showCheckboxColumn: false,
                    columns: const [
                      DataColumn(label: Text('VEHICLE')),
                      DataColumn(label: Text('ADDRESS')),
                      DataColumn(label: Text('START TIME')),
                      DataColumn(label: Text('END TIME')),
                    ],
                    rows: parkings.map((parking) {
                      final isSelected = parking == _selectedParking;

                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          setState(() {
                            _selectedParking =
                                selected == true ? parking : null;
                          });
                        },
                        color: WidgetStateProperty.resolveWith<Color?>(
                          (states) => isSelected ? Colors.blue[100] : null,
                        ),
                        cells: [
                          DataCell(Text(
                              parking.vehicle.target?.licensePlate ?? 'N/A')),
                          DataCell(Text(
                              parking.parkingSpace.target?.address ?? 'N/A')),
                          DataCell(Text(timeFormat.format(parking.startTime))),
                          DataCell(Text(parking.endTime != null
                              ? timeFormat.format(parking.endTime!)
                              : 'Ongoing')),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          // BottomActionButtons(
          //   onNew: _createParking,
          //   onEdit: () {}, // Add edit logic when needed
          //   onDelete: _deleteParking,
          //   onReload: _loadParkings,
          // ),
        ],
      ),
    );
  }
}
