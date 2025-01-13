// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/vehicles/vehicles_bloc.dart';
import '../bloc/vehicles/vehicles_event.dart';
import '../bloc/vehicles/vehicles_state.dart';
import 'package:shared/shared.dart';
import '../app_constants.dart';
import '../app_theme.dart';
import '../utils/validators.dart';
import '../widgets/app_bar_actions.dart';
import '../widgets/bottom_action_buttons.dart';

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
                  onPressed: () => context.read<VehiclesBloc>().add(LoadVehicles()),
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
                        final isSelected = vehicle == context.select<VehiclesBloc, Vehicle?>((bloc) => bloc.state.selectedVehicle);
                        return DataRow(
                          selected: isSelected,
                          onSelectChanged: (selected) {
                            context.read<VehiclesBloc>().add(SelectVehicle(vehicle: vehicle));
                          },
                          color: WidgetStateColor.resolveWith((states) => isSelected ? Colors.blue[100]! : Colors.transparent),
                          cells: [
                            DataCell(Text(vehicle.licensePlate)),
                            DataCell(Text(vehicle.vehicleType)),
                            DataCell(Text(vehicle.owner.target?.name ?? 'Unknown')),
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
          final newVehicle = await _createVehicleDialog(context);
          if (newVehicle != null) {
            context.read<VehiclesBloc>().add(CreateVehicle(
              licensePlate: newVehicle.licensePlate,
              vehicleType: newVehicle.vehicleType,
              vehicle: newVehicle,
            ));
          }
        },
        onEdit: () async {
          final selectedVehicle = context.read<VehiclesBloc>().state.selectedVehicle;
          if (selectedVehicle != null) {
            final updatedVehicle = await _editVehicleDialog(context, selectedVehicle);
            if (updatedVehicle != null) {
              context.read<VehiclesBloc>().add(UpdateVehicle(
                vehicleId: updatedVehicle.id,
                updatedVehicle: updatedVehicle,
              ));
            }
          }
        },
        onDelete: () {
          final selectedVehicle = context.read<VehiclesBloc>().state.selectedVehicle;
          if (selectedVehicle != null) {
            context.read<VehiclesBloc>().add(DeleteVehicle(vehicleId: selectedVehicle.id));
          }
        },
        onReload: () {
          context.read<VehiclesBloc>().add(ReloadVehicles());
        },
      ),
    );
  }

  Future<Vehicle?> _createVehicleDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final licensePlateController = TextEditingController();
    String? selectedVehicleType;

    return showDialog<Vehicle>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Vehicle'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: licensePlateController,
                  decoration: const InputDecoration(labelText: 'License Plate'),
                  validator: Validators.validateLicensePlate, // Use the centralized validator
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: vehicleTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) => selectedVehicleType = value,
                  validator: (value) => value == null ? 'Please select a type' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final vehicle = Vehicle(
                    licensePlate: licensePlateController.text,
                    vehicleType: selectedVehicleType!,
                  );
                  Navigator.of(context).pop(vehicle);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<Vehicle?> _editVehicleDialog(BuildContext context, Vehicle vehicle) async {
    final formKey = GlobalKey<FormState>();
    final licensePlateController = TextEditingController(text: vehicle.licensePlate);
    String? selectedVehicleType = vehicle.vehicleType;

    return showDialog<Vehicle>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Vehicle'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: licensePlateController,
                  decoration: const InputDecoration(labelText: 'License Plate'),
                  validator: Validators.validateLicensePlate, // Use the centralized validator
                ),
                DropdownButtonFormField<String>(
                  value: selectedVehicleType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: vehicleTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) => selectedVehicleType = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final updatedVehicle = Vehicle(
                    licensePlate: licensePlateController.text,
                    vehicleType: selectedVehicleType!,
                    id: vehicle.id,
                  );
                  Navigator.of(context).pop(updatedVehicle);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
