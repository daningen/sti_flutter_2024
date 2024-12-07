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
  Future<List<Parking>> getParkings = ParkingRepository().getAll();
  Future<List<ParkingSpace>> getAvailableParkingSpaces =
      ParkingSpaceRepository().getAll();
  Future<List<Vehicle>> getUserVehicles = VehicleRepository().getAll();

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().username;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                getParkings = ParkingRepository().getAll();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Parking>>(
        future: getParkings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No parking records found.'));
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
                trailing: parking.endTime == null
                    ? ElevatedButton(
                        onPressed: () async {
                          await ParkingRepository().stop(parking.id);
                          setState(() {
                            getParkings = ParkingRepository().getAll();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Parking stopped')),
                          );
                        },
                        child: const Text('Stop'),
                      )
                    : const Text('Completed'),
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
          FloatingActionButton(
            heroTag: 'addParking',
            onPressed: () async {
              var parkingsSnapshot = await getParkings;
              var result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) {
                  final formKey = GlobalKey<FormState>();
                  Vehicle? selectedVehicle;
                  ParkingSpace? selectedParkingSpace;

                  return AlertDialog(
                    title: const Text('Create New Parking'),
                    content: FutureBuilder<List<Vehicle>>(
                      future: getUserVehicles,
                      builder: (context, vehicleSnapshot) {
                        if (vehicleSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (vehicleSnapshot.hasError) {
                          return Text('Error: ${vehicleSnapshot.error}');
                        }

                        final vehicles = vehicleSnapshot.data
                                ?.where(
                                    (v) => v.owner.target?.name == currentUser)
                                .toList() ??
                            [];
                        return FutureBuilder<List<ParkingSpace>>(
                          future: getAvailableParkingSpaces,
                          builder: (context, parkingSpaceSnapshot) {
                            if (parkingSpaceSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            if (parkingSpaceSnapshot.hasError) {
                              return Text(
                                  'Error: ${parkingSpaceSnapshot.error}');
                            }

                            final parkingSpaces = parkingSpaceSnapshot.data
                                    ?.where((p) => !parkingsSnapshot.any(
                                        (parking) =>
                                            parking.parkingSpace.target?.id ==
                                                p.id &&
                                            parking.endTime == null))
                                    .toList() ??
                                [];
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
                                    items: parkingSpaces.map((space) {
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
                  getParkings = ParkingRepository().getAll();
                });
              }
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
