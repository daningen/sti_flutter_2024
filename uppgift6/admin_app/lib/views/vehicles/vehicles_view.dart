import 'package:admin_app/app_theme.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/bloc/person/person_bloc.dart';
import 'package:shared/bloc/person/person_event.dart';
import 'package:shared/bloc/vehicles/vehicles_bloc.dart';
import 'package:shared/bloc/vehicles/vehicles_event.dart';
import 'package:shared/bloc/vehicles/vehicles_state.dart';
import 'package:shared/shared.dart';
import '../../widgets/app_bar_actions.dart';
import '../../widgets/bottom_action_buttons.dart';
import 'dialogs/create_vehicle_dialog.dart';

class VehiclesView extends StatelessWidget {
  const VehiclesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles Management'),
        actions: const [
          AppBarActions(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<VehiclesBloc>().add(ReloadVehicles()); // Refresh vehicles
        },
        child: BlocBuilder<VehiclesBloc, VehicleState>(
          builder: (context, state) {
            if (state is VehicleInitial) {
              // Initial state: Show a button to load vehicles
              return Center(
                child: ElevatedButton(
                  onPressed: () =>
                      context.read<VehiclesBloc>().add(LoadVehicles()),
                  child: const Text("Load Vehicles"),
                ),
              );
            } else if (state is VehicleLoading) {
              // Loading state: Show a circular progress indicator
              return const Center(child: CircularProgressIndicator());
            } else if (state is VehicleLoaded) {
              // Loaded state: Display the vehicles in a DataTable
              final vehicles = state.vehicles;
              return SingleChildScrollView(  
                child: Center(
                  child: ConstrainedBox( 
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: DataTable(
                      headingRowColor: WidgetStateColor.resolveWith((states) {
                        return Theme.of(context).brightness == Brightness.dark
                            ? AppColors.headingRowColor
                            : Colors.grey[200]!;
                      }),
                      showCheckboxColumn: false,
                      columns: const [
                        DataColumn(label: Text('LICENSE PLATE')),
                        DataColumn(label: Text('TYPE')),
                        DataColumn(label: Text('OWNER')),
                      ],
                      rows: vehicles.map((vehicle) {
                        // Check if the vehicle is selected
                        final isSelected = vehicle ==
                            context.select<VehiclesBloc, Vehicle?>(
                                (bloc) => bloc.state.selectedVehicle);
                        return DataRow(
                          selected: isSelected,
                          onSelectChanged: (selected) {
                            // Select/deselect the vehicle
                            context
                                .read<VehiclesBloc>()
                                .add(SelectVehicle(vehicle: vehicle));
                          },
                          color: WidgetStateColor.resolveWith((states) =>
                              isSelected
                                  ? Colors.blue[100]!
                                  : Colors.transparent),
                          cells: [
                            DataCell(Text(vehicle.licensePlate)),
                            DataCell(Text(vehicle.vehicleType)),
                            DataCell(
                              // Fetch and display the owner's name using FutureBuilder
                              FutureBuilder<Person?>(
                                future: context
                                    .read<PersonRepository>()
                                    .getPersonByAuthId(vehicle.ownerAuthId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text("Loading...");
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        "Error: ${snapshot.error.toString()}");
                                  } else {
                                    final owner = snapshot.data;
                                    return Text(
                                        owner?.name ?? 'Unknown'); // Display owner name
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            } else if (state is VehicleError) {
              // Error state: Display an error message
              return Center(child: Text('Error: ${state.message}'));
            } else {
              // Other states: Return an empty SizedBox (no widget to display)
              return const SizedBox.shrink();
            }
          },
        ),
      ),
      bottomNavigationBar: BottomActionButtons(
        onNew: () async {
          debugPrint("onNew: Opening CreateVehicleDialog...");

          final ownersFuture = context.read<PersonRepository>().getAll();

          await showDialog(
            context: context,
            builder: (context) {
              return CreateVehicleDialog(
                ownersFuture: ownersFuture,
                onCreate: (newVehicle) {
                  debugPrint(
                      "onNew: Creating new vehicle: ${newVehicle.toJson()}");

                  context.read<VehiclesBloc>().add(CreateVehicle(
                        licensePlate: newVehicle.licensePlate,
                        vehicleType: newVehicle.vehicleType,
                        authId: newVehicle.authId, // authId of the creator
                        ownerAuthId: newVehicle.ownerAuthId, // ownerAuthId
                      ));

                  context.read<PersonBloc>().add(LoadPersons()); // Refresh person list
                },
              );
            },
          );

          debugPrint("onNew: CreateVehicleDialog closed.");
        },
        // todo fix this for admin
        // onEdit: () async {
        //   final selectedVehicle = context.read<VehiclesBloc>().state.selectedVehicle;
        //   if (selectedVehicle != null) {
        //     final ownersFuture = context.read<PersonRepository>().getAll();

        //     // Correct usage of showDialog and EditVehicleDialog
        //     await showDialog(
        //       context: context,
        //       builder: (context) => EditVehicleDialog( // Use EditVehicleDialog as a widget
        //         ownersFuture: ownersFuture,
        //         vehicle: selectedVehicle,
        //         onEdit: (updatedVehicle) {
        //           context.read<VehiclesBloc>().add(UpdateVehicle(
        //             vehicleId: updatedVehicle.id,
        //             updatedVehicle: updatedVehicle,
        //           ));

        //           context.read<PersonBloc>().add(LoadPersons());
        //         },
        //       ),
        //     );
        //   }
        // },
        onDelete: () {
          final selectedVehicle =
              context.read<VehiclesBloc>().state.selectedVehicle;
          if (selectedVehicle != null) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: Text(
                      'Do you want to delete the vehicle with license plate "${selectedVehicle.licensePlate}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<VehiclesBloc>()
                            .add(DeleteVehicle(vehicleId: selectedVehicle.id));
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Vehicle with license plate "${selectedVehicle.licensePlate}" deleted.')),
                        );
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          }
        },
        onReload: () {
          context.read<VehiclesBloc>().add(ReloadVehicles()); // Reload vehicles
        },
      ),
    );
  }
}