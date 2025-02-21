import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_app/providers/theme_notifier.dart';
import 'package:parking_app/views/vehicle/dialog/create_vehicle_dialog.dart';
import 'package:parking_app/views/vehicle/vehicle_navigation_bar.dart';
import 'package:shared/bloc/auth/auth_firebase_bloc.dart';
import 'package:shared/bloc/vehicles/vehicles_bloc.dart';
import 'package:shared/bloc/vehicles/vehicles_event.dart';
import 'package:shared/bloc/vehicles/vehicles_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class VehiclesView extends StatefulWidget {
  const VehiclesView({super.key});

  @override
  State<VehiclesView> createState() => _VehiclesViewState();
}

class _VehiclesViewState extends State<VehiclesView> {
  late VehiclesBloc _vehicleBloc;
  final _personRepository = PersonRepository();

  @override
  void initState() {
    super.initState();
    final authBloc = context.read<AuthFirebaseBloc>();
    _vehicleBloc = VehiclesBloc(
      vehicleRepository: VehicleRepository(db: FirebaseFirestore.instance),
      authFirebaseBloc: authBloc,
    );
    _vehicleBloc.add(LoadVehicles()); // Load vehicles when the view initializes
  }

  @override
  void dispose() {
    _vehicleBloc.close(); // Close the VehiclesBloc to prevent memory leaks
    super.dispose();
  }

  void refreshVehicles() {
    _vehicleBloc.add(ReloadVehicles()); // Reload vehicles data
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier =
        Provider.of<ThemeNotifier>(context); // Access theme notifier
    final authState = context.watch<AuthFirebaseBloc>().state;
    final userRole =
        (authState is AuthAuthenticated) ? authState.person.role : 'user';
    final loggedInUserAuthId =
        (authState is AuthAuthenticated) ? authState.user.uid : '';

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
            onPressed: themeNotifier.toggleTheme, // Toggle theme
          ),
        ],
      ),
      body: BlocProvider<VehiclesBloc>(
        create: (context) => _vehicleBloc, // Provide VehiclesBloc
        child: BlocBuilder<VehiclesBloc, VehicleState>(
          builder: (context, state) {
            if (state is VehicleLoading) {
              return const Center(
                  child: CircularProgressIndicator()); // Show loading indicator
            }

            if (state is VehicleError) {
              return Center(
                  child: Text('Error: ${state.message}')); // Show error message
            }

            if (state is VehicleLoaded) {
              final vehicles = state.vehicles;

              return ListView.builder(
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];

                  return FutureBuilder<Person?>(
                    // FutureBuilder to fetch owner
                    future: _personRepository
                        .getPersonByAuthId(vehicle.ownerAuthId),
                    builder: (context, snapshot) {
                      final owner = snapshot.data;
                      return VehicleListItem(
                          vehicle: vehicle,
                          owner: owner); // Use separate widget
                    },
                  );
                },
              );
            }

            return const SizedBox(); // Empty widget for other states
          },
        ),
      ),
      bottomNavigationBar: VehicleNavigationBar(
        onHomePressed: () => context.go('/'), // Navigate to home
        onReloadPressed: refreshVehicles, // Refresh vehicles list
        onAddVehiclePressed: () async {
          final persons = await _personRepository.getAll(); // Fetch all persons

          if (persons.isEmpty) {
            debugPrint(
                "⚠️ No persons found. Ensure persons exist in Firestore.");
          }

          final newVehicle = await showDialog<Vehicle>(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) => CreateVehicleDialog(
              owners: Future.value(persons), // Pass persons to dialog
              userRole: userRole,
              loggedInUserAuthId: loggedInUserAuthId,
            ),
          );

          if (newVehicle != null) {
            _vehicleBloc.add(
              CreateVehicle(
                licensePlate: newVehicle.licensePlate,
                vehicleType: newVehicle.vehicleType,
                authId: newVehicle.authId,
                ownerAuthId: newVehicle.ownerAuthId,
              ),
            );
          }
        },
        onLogoutPressed: () {
          debugPrint('Logout pressed');
          context.go('/login'); // Navigate to login
        },
      ),
    );
  }
}

// Separate widget for the list item
class VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;
  final Person? owner;

  const VehicleListItem(
      {super.key, required this.vehicle, required this.owner});

  @override
  Widget build(BuildContext context) {
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
              content:
                  const Text('Are you sure you want to delete this vehicle?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );

          if (confirmDelete == true) {
            // ignore: use_build_context_synchronously
            context
                .read<VehiclesBloc>()
                .add(DeleteVehicle(vehicleId: vehicle.id));
          }
        },
      ),
    );
  }
}
