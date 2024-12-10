// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';
import 'package:parking_app/auth_service.dart';
import 'package:provider/provider.dart';

class ParkingView extends StatefulWidget {
  const ParkingView({super.key});

  @override
  State<ParkingView> createState() => _ParkingViewState();
}

class _ParkingViewState extends State<ParkingView> {
  late Future<List<Parking>> ongoingParkings;
  late Future<List<Parking>> allParkings;

  @override
  void initState() {
    super.initState();
    loadParkings();
  }

  void loadParkings() {
    final currentUser = context.read<AuthService>().username;
    if (currentUser.isEmpty) {
      ongoingParkings = Future.value([]);
      allParkings = Future.value([]);
      return;
    }

    debugPrint('Loading parkings for user: $currentUser');
    ongoingParkings = ParkingRepository().getAll().then((parkings) {
      final ongoing = parkings.where((p) =>
          p.vehicle.target?.owner.target?.name == currentUser &&
          p.endTime == null);
      debugPrint('Ongoing parkings: ${ongoing.toList()}');
      return ongoing.toList();
    });

    allParkings = ParkingRepository().getAll().then((parkings) {
      final all = parkings
          .where((p) => p.vehicle.target?.owner.target?.name == currentUser);
      debugPrint('All parkings: ${all.toList()}');
      return all.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                loadParkings();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Parking>>(
        future: ongoingParkings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load data: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No ongoing parking records found.'));
          }

          final parkings = snapshot.data!;
          return ListView.builder(
            itemCount: parkings.length,
            itemBuilder: (context, index) {
              final parking = parkings[index];
              return ListTile(
                title: Text(
                  'Parking at ${parking.parkingSpace.target?.address ?? 'Unknown'}',
                ),
                subtitle: Text(
                  'Vehicle: ${parking.vehicle.target?.licensePlate ?? 'Unknown'}\n'
                  'Start Time: ${parking.startTime}',
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    try {
                      await ParkingRepository().stop(parking.id);
                      debugPrint('Stopped parking: ${parking.id}');
                      setState(() {
                        loadParkings();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Parking stopped')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to stop parking: $e')),
                      );
                    }
                  },
                  child: const Text('Stop'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'home',
            onPressed: () {
              context.go('/'); // Navigate to the home page
            },
            child: const Icon(Icons.home),
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: 'history',
            onPressed: () async {
              setState(() {
                loadParkings();
              });
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Parking History'),
                    content: FutureBuilder<List<Parking>>(
                      future: allParkings,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No parking history found.');
                        }

                        final parkings = snapshot.data!;
                        return SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: parkings.length,
                            itemBuilder: (context, index) {
                              final parking = parkings[index];
                              return ListTile(
                                title: Text(
                                  'Parking at ${parking.parkingSpace.target?.address ?? 'Unknown'}',
                                ),
                                subtitle: Text(
                                  'Vehicle: ${parking.vehicle.target?.licensePlate ?? 'Unknown'}\n'
                                  'Start Time: ${parking.startTime}\n'
                                  'End Time: ${parking.endTime ?? 'Ongoing'}',
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            label: const Text('History'),
            icon: const Icon(Icons.history),
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: 'addParking',
            onPressed: () async {
              final currentUser = context.read<AuthService>().username;

              // Fetch all parking spaces and parking records
              var availableParkingSpaces =
                  await ParkingSpaceRepository().getAll();
              var parkingsSnapshot = await ParkingRepository().getAll();

              // Fetch all vehicles for the current user
              var allVehicles = await VehicleRepository().getAll();
              var availableVehicles = allVehicles.where((v) {
                final isOwnedByCurrentUser =
                    v.owner.target?.name == currentUser;
                final hasOngoingParking = parkingsSnapshot.any((parking) =>
                    parking.vehicle.target?.id == v.id &&
                    parking.endTime == null);
                return isOwnedByCurrentUser && !hasOngoingParking;
              }).toList();

              // Filter out parking spaces already in use
              availableParkingSpaces = availableParkingSpaces
                  .where((space) => !parkingsSnapshot.any((parking) =>
                      parking.parkingSpace.target?.id == space.id &&
                      parking.endTime == null))
                  .toList();

              var result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) {
                  final formKey = GlobalKey<FormState>();
                  Vehicle? selectedVehicle;
                  ParkingSpace? selectedParkingSpace;

                  return AlertDialog(
                    title: const Text('Create New Parking'),
                    content: FutureBuilder<List<Vehicle>>(
                      future: Future.value(
                          availableVehicles), // Pass filtered vehicles
                      builder: (context, vehicleSnapshot) {
                        if (vehicleSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (vehicleSnapshot.hasError) {
                          return Text('Error: ${vehicleSnapshot.error}');
                        }

                        final vehicles = vehicleSnapshot.data ?? [];
                        if (vehicles.isEmpty) {
                          return const Text(
                              'No available vehicles for parking.');
                        }

                        return Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButtonFormField<Vehicle>(
                                decoration: const InputDecoration(
                                    labelText: 'Select Vehicle'),
                                items: vehicles.map((vehicle) {
                                  return DropdownMenuItem<Vehicle>(
                                    value: vehicle,
                                    child: Text(vehicle.licensePlate),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  selectedVehicle = value;
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a vehicle';
                                  }
                                  return null;
                                },
                              ),
                              DropdownButtonFormField<ParkingSpace>(
                                decoration: const InputDecoration(
                                    labelText: 'Select Parking Space'),
                                items: availableParkingSpaces.map((space) {
                                  return DropdownMenuItem<ParkingSpace>(
                                    value: space,
                                    child: Text(space.address),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  selectedParkingSpace = value;
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a parking space';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.of(context).pop({
                              'vehicle': selectedVehicle,
                              'parkingSpace': selectedParkingSpace,
                            });
                          }
                        },
                        child: const Text('Create'),
                      ),
                    ],
                  );
                },
              );

              if (result != null) {
                final parking = Parking(
                  startTime: DateTime.now(),
                );

                parking.setDetails(result['vehicle'], result['parkingSpace']);

                await ParkingRepository().create(parking);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Parking created successfully')),
                );

                setState(() {
                  loadParkings();
                });
              }
            },
            label: const Text('Add Parking'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
