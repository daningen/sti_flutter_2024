import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_app/providers/theme_notifier.dart';
import 'package:parking_app/views/vehicle/dialog/create_vehicle_dialog.dart';
import 'package:parking_app/views/vehicle/vehicle_navigation_bar.dart'; // Import the custom navigation bar

// Import VehicleBloc and related events/states
import 'package:shared/bloc/vehicles/vehicles_bloc.dart';
import 'package:shared/bloc/vehicles/vehicles_event.dart';
import 'package:shared/bloc/vehicles/vehicles_state.dart';

import 'package:provider/provider.dart';
import 'package:shared/shared.dart'; // Import for ThemeNotifier

class VehiclesView extends StatefulWidget {
  const VehiclesView({super.key});

  @override
  State<VehiclesView> createState() => _VehiclesViewState();
}

class _VehiclesViewState extends State<VehiclesView> {
  final _vehicleBloc = VehiclesBloc(vehicleRepository: VehicleRepository());

  @override
  void initState() {
    super.initState();
    _vehicleBloc.add(LoadVehicles()); // Load vehicles on view initialization
  }

  @override
  void dispose() {
    _vehicleBloc.close(); // Close the bloc when the view is disposed
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
            onPressed: () {
              themeNotifier.toggleTheme();
            },
          ),
        ],
      ),
      body: BlocProvider<VehiclesBloc>(
        create: (context) => _vehicleBloc,
        child: BlocBuilder<VehiclesBloc, VehicleState>(
          bloc: _vehicleBloc,
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
                                    _vehicleBloc.add(
                                        DeleteVehicle(vehicleId: vehicle.id));
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox(); // Handle unexpected states
          },
        ),
      ),
      bottomNavigationBar: VehicleNavigationBar(
  onHomePressed: () {
    context.go('/'); // Navigate to home
  },
  onReloadPressed: () {
    refreshVehicles(); 
  },
  onAddVehiclePressed: () async {
    // Open CreateVehicleDialog
    await showDialog<void>(
      context: context,
      builder: (context) => CreateVehicleDialog(
        onCreate: (newVehicle) => _vehicleBloc.add(CreateVehicle(
          licensePlate: newVehicle.licensePlate,
          vehicleType: newVehicle.vehicleType,
          owner: newVehicle.owner.target ??
              Person(name: 'Unknown', ssn: '000000'),
        )),
        ownersFuture: PersonRepository().getAll(),
      ),
    );
  },
  onLogoutPressed: () {
    // Implement logout functionality !!!!!!
    debugPrint('Logout pressed');
    context.go('/login'); 
  },
),

    );
  }
}
