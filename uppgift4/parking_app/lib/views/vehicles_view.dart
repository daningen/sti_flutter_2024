// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';
import 'package:provider/provider.dart';
import '../auth_service.dart';

class VehiclesView extends StatefulWidget {
  const VehiclesView({super.key});

  @override
  State<VehiclesView> createState() => _VehiclesViewState();
}

class _VehiclesViewState extends State<VehiclesView> {
  late Future<List<Vehicle>> getVehicles;
  Future<List<Person>> getPersons = PersonRepository().getAll();

  @override
  void initState() {
    super.initState();
    refreshVehicles();
  }

  void refreshVehicles() {
    final loggedInUser = context.read<AuthService>().username;
    getVehicles = VehicleRepository().getAll().then((vehicles) =>
        vehicles.where((v) => v.owner.target?.name == loggedInUser).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of Vehicles'),
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: getVehicles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No vehicles found'));
          }

          final vehicles = snapshot.data!;
          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              final owner = vehicle.owner.target;
              return ListTile(
                title: Text(
                  'License Plate: ${vehicle.licensePlate}, Type: ${vehicle.vehicleType}, Owner: ${owner?.name ?? 'Unknown'} (SSN: ${owner?.ssn ?? 'Unknown'})',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: const Text(
                                'Are you sure you want to delete this vehicle?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmDelete == true) {
                          await VehicleRepository().delete(vehicle.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Vehicle deleted successfully')));
                          setState(() {
                            refreshVehicles();
                          });
                        }
                      },
                    ),
                  ],
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
              context.go('/');
            },
            child: const Icon(Icons.home),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'reload',
            onPressed: () {
              setState(() {
                refreshVehicles();
              });
            },
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: 'addVehicle',
            onPressed: () async {
              var result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) {
                  final licensePlateController = TextEditingController();
                  String? selectedVehicleType;
                  Person? selectedOwner;
                  final formKey = GlobalKey<FormState>();

                  return AlertDialog(
                    title: const Text("Create new vehicle"),
                    content: FutureBuilder<List<Person>>(
                      future: getPersons,
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
                          return const Text('No owners available');
                        }

                        final persons = snapshot.data!;
                        return Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: licensePlateController,
                                decoration: const InputDecoration(
                                  labelText: "License Plate",
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a license plate';
                                  }
                                  if (!RegExp(r'^[A-Za-z]{3}[0-9]{3}$')
                                      .hasMatch(value)) {
                                    return 'License plate must be in format ABC123';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  licensePlateController.value =
                                      TextEditingValue(
                                    text: value.toUpperCase(),
                                    selection: licensePlateController.selection,
                                  );
                                },
                              ),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: "Vehicle Type",
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: "Car",
                                    child: Text("Car"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Motorcycle",
                                    child: Text("Motorcycle"),
                                  ),
                                ],
                                onChanged: (value) {
                                  selectedVehicleType = value;
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a vehicle type';
                                  }
                                  return null;
                                },
                              ),
                              DropdownButtonFormField<Person>(
                                decoration: const InputDecoration(
                                  labelText: "Select Owner",
                                ),
                                items: persons.map((person) {
                                  return DropdownMenuItem<Person>(
                                    value: person,
                                    child: Text(person.name),
                                  );
                                }).toList(),
                                onChanged: (person) {
                                  selectedOwner = person;
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select an owner';
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
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.of(context).pop({
                              'licensePlate': licensePlateController.text,
                              'vehicleType': selectedVehicleType,
                              'owner': selectedOwner,
                            });
                          }
                        },
                        child: const Text("Create"),
                      ),
                    ],
                  );
                },
              );

              if (result != null) {
                debugPrint(
                    'Result is not null, attempting to create vehicle...');
                final newVehicle = Vehicle(
                  licensePlate: result['licensePlate'],
                  vehicleType: result['vehicleType'],
                );

                newVehicle.setOwner(result['owner']);

                try {
                  await VehicleRepository().create(newVehicle);
                  debugPrint('Vehicle created successfully in repository');

                  if (mounted) {
                    debugPrint('Mounted is true, showing SnackBar');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vehicle created successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    setState(() {
                      debugPrint('Refreshing vehicles...');
                      refreshVehicles();
                    });
                  } else {
                    debugPrint('Mounted is false, not showing SnackBar');
                  }
                } catch (e) {
                  debugPrint('Error creating vehicle: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create vehicle: $e')),
                  );
                }
              }
            },
            label: const Text("Add Vehicle"),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
