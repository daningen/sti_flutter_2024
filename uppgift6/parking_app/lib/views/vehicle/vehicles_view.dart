import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_app/providers/theme_notifier.dart';
import 'package:parking_app/views/vehicle/dialog/create_vehicle_dialog.dart';
import 'package:parking_app/views/vehicle/vehicle_navigation_bar.dart';

import 'package:shared/bloc/vehicles/vehicles_bloc.dart';
import 'package:shared/bloc/vehicles/vehicles_event.dart';
import 'package:shared/bloc/vehicles/vehicles_state.dart';

import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class VehiclesView extends StatefulWidget {
  const VehiclesView({super.key});

  @override
  State<VehiclesView> createState() => _VehiclesViewState();
}

class _VehiclesViewState extends State<VehiclesView> {
  late VehiclesBloc _vehicleBloc;
  final _personRepository = PersonRepository(); // Single instance for efficiency

  @override
  void initState() {
    super.initState();
    _vehicleBloc = VehiclesBloc(vehicleRepository: VehicleRepository());
    _vehicleBloc.add(LoadVehicles());
  }

  @override
  void dispose() {
    _vehicleBloc.close();
    super.dispose();
  }

  void refreshVehicles() {
    _vehicleBloc.add(ReloadVehicles());
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('List of Vehicles'),
        actions: [
          IconButton(
            icon: Icon(
              themeNotifier.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: themeNotifier.toggleTheme,
          ),
        ],
      ),
      body: BlocProvider<VehiclesBloc>(
        create: (context) => _vehicleBloc,
        child: BlocBuilder<VehiclesBloc, VehicleState>(
          builder: (context, state) {
            if (state is VehicleLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is VehicleError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is VehicleLoaded) {
              final vehicles = state.vehicles;

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        final owner = vehicle.owner; // Access owner safely

                        return ListTile(
                          title: Text(
                            'License Plate: ${vehicle.licensePlate}, '
                            'Type: ${vehicle.vehicleType}, '
                            'Owner: ${owner?.name ?? 'Unknown'} '
                            '(SSN: ${owner?.ssn ?? 'Unknown'})',
                          ),
                          trailing: IconButton(
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
                                _vehicleBloc.add(DeleteVehicle(vehicleId: vehicle.id));
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox(); // Fallback for unexpected states
          },
        ),
      ),
      bottomNavigationBar: VehicleNavigationBar(
        onHomePressed: () => context.go('/'), // Navigate to home
        onReloadPressed: refreshVehicles,
        onAddVehiclePressed: () async {
          final persons = await _personRepository.getAll(); // Fetch owners

          if (persons.isEmpty) {
            debugPrint("⚠️ No persons found. Ensure persons exist in Firestore.");
          }

          await showDialog<void>(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) => CreateVehicleDialog(
              ownersFuture: Future.value(persons), // Pass fetched persons
              onCreate: (newVehicle) {
                final owner = newVehicle.owner ??
                    Person(
                      id: '',
                      authId: '', // Ensure authId field is handled
                      name: 'Unknown',
                      ssn: '000000',
                    );

                _vehicleBloc.add(
                  CreateVehicle(
                    licensePlate: newVehicle.licensePlate,
                    vehicleType: newVehicle.vehicleType,
                    owner: owner.copyWith(), // Ensure immutability
                  ),
                );
              },
            ),
          );
        },
        onLogoutPressed: () {
          debugPrint('Logout pressed');
          context.go('/login');
        },
      ),
    );
  }
}
