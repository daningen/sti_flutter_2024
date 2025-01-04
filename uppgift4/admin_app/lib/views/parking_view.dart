// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:admin_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';
import '../widgets/app_bar_actions.dart';
import '../widgets/bottom_action_buttons.dart.dart';

class ParkingView extends StatefulWidget {
  const ParkingView({super.key});

  @override
  State<ParkingView> createState() => _ParkingViewState();
}

class _ParkingViewState extends State<ParkingView> {
  late Future<List<Parking>> _parkingsFuture;
  // ignore: unused_field
  late Future<void> _initialDataLoad;
  Parking? _selectedParking;
  bool _showActiveOnly = false;

  // Prefetched data
  List<ParkingSpace> _parkingSpaces = [];
  List<Vehicle> _vehicles = [];

  final DateFormat timeFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    _initialDataLoad = _prefetchData();
    _loadParkings();
  }

  Future<void> _prefetchData() async {
    try {
      final vehicles = await VehicleRepository().getAll();
      final parkingSpaces = await ParkingSpaceRepository().getAll();
      setState(() {
        _vehicles = vehicles;
        _parkingSpaces = parkingSpaces;
      });
    } catch (e) {
      debugPrint('Error prefetching data: $e');
    }
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

  void _createParking() async {
    String? selectedVehicle;
    String? selectedParkingSpace;

    if (_vehicles.isEmpty || _parkingSpaces.isEmpty) {
      debugPrint('No prefetched data available.');
      return;
    }

    final ongoingSessions = (await ParkingRepository().getAll())
        .where((p) => p.endTime == null)
        .toList();

    final availableVehicles = _vehicles.where((vehicle) {
      return !ongoingSessions
          .any((session) => session.vehicle.target?.id == vehicle.id);
    }).toList();

    final availableParkingSpaces = _parkingSpaces.where((space) {
      return !ongoingSessions
          .any((session) => session.parkingSpace.target?.id == space.id);
    }).toList();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Parking'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Select Vehicle'),
                    items: availableVehicles
                        .map((vehicle) => DropdownMenuItem(
                              value: vehicle.id.toString(),
                              child: Text(vehicle.licensePlate),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedVehicle = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Select Parking Space'),
                    items: availableParkingSpaces
                        .map((space) => DropdownMenuItem(
                              value: space.id.toString(),
                              child: Text(space.address),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedParkingSpace = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedVehicle != null &&
                        selectedParkingSpace != null) {
                      final selectedVehicleData = availableVehicles.firstWhere(
                          (vehicle) =>
                              vehicle.id.toString() == selectedVehicle);

                      final selectedParkingSpaceData =
                          availableParkingSpaces.firstWhere((space) =>
                              space.id.toString() == selectedParkingSpace);

                      final newParking = Parking(
                        startTime: DateTime.now(),
                      );
                      newParking.setDetails(
                        selectedVehicleData,
                        selectedParkingSpaceData,
                      );
                      await ParkingRepository().create(newParking);
                      debugPrint('Parking created: $newParking');
                      _loadParkings(); // Reload data after creation
                      Navigator.of(context).pop();
                    } else {
                      debugPrint('All fields must be selected.');
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking'),
        actions: const [
          AppBarActions(), // Use shared AppBarActions
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
                    headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                      if (Theme.of(context).brightness == Brightness.dark) {
                        return AppColors.headingRowColor;
                      }
                      return null;
                    }),
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
                            (states) => isSelected ? Colors.blue[100] : null),
                        cells: [
                          DataCell(Text(
                              parking.vehicle.target?.licensePlate ?? 'N/A')),
                          DataCell(Text(
                              parking.parkingSpace.target?.address ?? 'N/A')),
                          DataCell(Text(timeFormat.format(parking.startTime))),
                          DataCell(
                            parking.endTime != null
                                ? Text(timeFormat.format(parking.endTime!))
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor:
                                          Colors.red, // Button text color
                                    ),
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Confirm Stop Parking'),
                                            content: const Text(
                                                'Are you sure you want to stop this parking session?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                  parking.endTime =
                                                      DateTime.now();
                                                  await ParkingRepository()
                                                      .stop(parking.id);
                                                  setState(() {
                                                    // Force a rebuild
                                                  });
                                                  _loadParkings(); // Reload data for future updates
                                                },
                                                child: const Text('Stop'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: const Text('Stop'),
                                  ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          BottomActionButtons(
            onNew: _createParking,
            onEdit: () {},
            onDelete: () {},
            onReload: _loadParkings,
          ),
        ],
      ),
    );
  }
}
