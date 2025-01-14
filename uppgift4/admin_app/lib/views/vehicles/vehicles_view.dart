// ignore_for_file: use_build_context_synchronously

import 'package:admin_app/app_theme.dart';
// import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/vehicles/vehicles_bloc.dart';
import '../../bloc/vehicles/vehicles_event.dart';
import '../../bloc/vehicles/vehicles_state.dart';
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
                                Text(vehicle.owner.target?.name ?? 'Unknown')),
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
          await showDialog(
            context: context,
            builder: (context) {
              return CreateVehicleDialog(
                ownersFuture: context.read<VehiclesBloc>().state
                        is VehicleLoaded
                    ? Future.value(
                        (context.read<VehiclesBloc>().state as VehicleLoaded)
                            .vehicles
                            .map((v) => v.owner.target)
                            .whereType<Person>()
                            .toList())
                    : Future.value([]),
                onCreate: (newVehicle) {
                  context.read<VehiclesBloc>().add(CreateVehicle(
                        licensePlate: newVehicle.licensePlate,
                        vehicleType: newVehicle.vehicleType,
                        owner: newVehicle.owner.target ??
                            Person(name: 'Unknown', ssn: '000000'),
                      ));
                },
              );
            },
          );
        },
        onEdit: () async {
          final selectedVehicle =
              context.read<VehiclesBloc>().state.selectedVehicle;
          if (selectedVehicle != null) {
            await showDialog(
              context: context,
              builder: (context) {
                return EditVehicleDialog(
                  ownersFuture: context.read<VehiclesBloc>().state
                          is VehicleLoaded
                      ? Future.value(
                          (context.read<VehiclesBloc>().state as VehicleLoaded)
                              .vehicles
                              .map((v) => v.owner.target)
                              .whereType<Person>()
                              .toList())
                      : Future.value([]),
                  vehicle: selectedVehicle,
                  onEdit: (updatedVehicle) {
                    context.read<VehiclesBloc>().add(UpdateVehicle(
                          vehicleId: updatedVehicle.id,
                          updatedVehicle: updatedVehicle,
                        ));
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
