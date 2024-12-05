// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart'; // Ensure that the Vehicle and Person models are imported correctly
import 'package:go_router/go_router.dart'; // Add this import for GoRouter

class VehiclesView extends StatefulWidget {
  const VehiclesView({super.key});

  @override
  State<VehiclesView> createState() => _VehiclesViewState();
}

class _VehiclesViewState extends State<VehiclesView> {
  Future<List<Vehicle>> getVehicles = VehicleRepository().getAll();
  Future<List<Person>> getPersons = PersonRepository().getAll();

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
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await VehicleRepository().delete(vehicle.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Vehicle deleted successfully')),
                    );

                    // Reload vehicles after deletion
                    setState(() {
                      getVehicles = VehicleRepository().getAll();
                    });
                  },
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
              // Use context.go('/') to explicitly navigate to the home page
              context.go('/'); // Go back to the start page
            },
            child: const Icon(Icons.home),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'reload',
            onPressed: () {
              // Reload the vehicles
              setState(() {
                getVehicles = VehicleRepository().getAll();
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
                  final vehicleTypeController = TextEditingController();
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
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: vehicleTypeController,
                                decoration: const InputDecoration(
                                  labelText: "Vehicle Type",
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a vehicle type';
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
                              'vehicleType': vehicleTypeController.text,
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
                final newVehicle = Vehicle(
                  licensePlate: result['licensePlate'],
                  vehicleType: result['vehicleType'],
                );

                // Set the selected owner for the vehicle
                newVehicle.setOwner(result['owner']);

                // Create the vehicle using the repository
                await VehicleRepository().create(newVehicle);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vehicle created successfully')),
                );

                // Reload the list of vehicles
                setState(() {
                  getVehicles = VehicleRepository().getAll();
                });
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
