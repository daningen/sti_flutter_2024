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
import 'dialogs/edit_vehicle_dialog.dart';

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
          context.read<VehiclesBloc>().add(ReloadVehicles());
        },
        child: BlocBuilder<VehiclesBloc, VehicleState>(
          builder: (context, state) {
            if (state is VehicleInitial) {
              return Center(
                child: ElevatedButton(
                  onPressed: () =>
                      context.read<VehiclesBloc>().add(LoadVehicles()),
                  child: const Text("Load Vehicles"),
                ),
              );
            } else if (state is VehicleLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is VehicleLoaded) {
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
                        final isSelected = vehicle ==
                            context.select<VehiclesBloc, Vehicle?>(
                                (bloc) => bloc.state.selectedVehicle);
                        return DataRow(
                          selected: isSelected,
                          onSelectChanged: (selected) {
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
                              Text(vehicle.owner?.name ?? 'Unknown'),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            } else if (state is VehicleError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
      bottomNavigationBar: BottomActionButtons(
        onNew: () async {
          debugPrint("onNew: Opening CreateVehicleDialog...");

          // Fetch all owners from the repository
          final ownersFuture = context.read<PersonRepository>().getAll();

          await showDialog(
            context: context,
            builder: (context) {
              return CreateVehicleDialog(
                ownersFuture: ownersFuture,
                onCreate: (newVehicle) {
                  debugPrint(
                      "onNew: Creating new vehicle: ${newVehicle.toJson()}");

                  // Dispatch the create event
                  context.read<VehiclesBloc>().add(CreateVehicle(
                        licensePlate: newVehicle.licensePlate,
                        vehicleType: newVehicle.vehicleType,
                        owner: newVehicle.owner ??
                            Person(id: '', name: 'Unknown', ssn: '000000'),
                      ));

                  // Reload persons after a successful create
                  context.read<PersonBloc>().add(LoadPersons());
                },
              );
            },
          );

          debugPrint("onNew: CreateVehicleDialog closed.");
        },
        onEdit: () async {
          final selectedVehicle =
              context.read<VehiclesBloc>().state.selectedVehicle;
          if (selectedVehicle != null) {
            // Fetch all owners from the repository
            final ownersFuture = context.read<PersonRepository>().getAll();

            // Show the edit dialog
            await showDialog(
              context: context,
              builder: (context) {
                return EditVehicleDialog(
                  ownersFuture: ownersFuture,
                  vehicle: selectedVehicle,
                  onEdit: (updatedVehicle) {
                    // Dispatch the update event
                    context.read<VehiclesBloc>().add(UpdateVehicle(
                          vehicleId: updatedVehicle.id,
                          updatedVehicle: updatedVehicle,
                        ));

                    // Reload persons after a successful update
                    context.read<PersonBloc>().add(LoadPersons());
                  },
                );
              },
            );
          }
        },
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
          context.read<VehiclesBloc>().add(ReloadVehicles());
        },
      ),
    );
  }
}
