// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:admin_app/views/parking/dialog/edit_parking_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared/bloc/parkings/parking_bloc.dart';
import 'package:shared/bloc/parkings/parking_event.dart';
import 'package:shared/bloc/parkings/parking_state.dart';

import '../../widgets/app_bar_actions.dart';
import '../../widgets/bottom_action_buttons.dart';
import 'dialog/create_parking_dialog.dart';

class ParkingView extends StatelessWidget {
  const ParkingView({super.key});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Management'),
        actions: const [AppBarActions()],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ParkingBloc>().add(LoadParkings());
        },
        child: BlocBuilder<ParkingBloc, ParkingState>(
          builder: (context, state) {
            if (state is ParkingLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ParkingLoaded) {
              final parkings = state.parkings;

              return SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.resolveWith(
                        (states) =>
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[200],
                      ),
                      showCheckboxColumn: false,
                      columns: const [
                        DataColumn(label: Text('VEHICLE')),
                        DataColumn(label: Text('ADDRESS')),
                        DataColumn(label: Text('START TIME')),
                        DataColumn(label: Text('END TIME')),
                      ],
                      rows: parkings.map((parking) {
                        final isSelected = parking == state.selectedParking;

                        return DataRow(
                          selected: isSelected,
                          onSelectChanged: (selected) {
                            context.read<ParkingBloc>().add(SelectParking(
                                selectedParking:
                                    selected == true ? parking : null));
                          },
                          color: MaterialStateProperty.resolveWith(
                            (states) => isSelected
                                ? Colors.blue[100]
                                : Colors.transparent,
                          ),
                          cells: [
                            DataCell(Text(
                                parking.vehicle.target?.licensePlate ?? 'N/A')),
                            DataCell(Text(
                                parking.parkingSpace.target?.address ?? 'N/A')),
                            DataCell(
                                Text(timeFormat.format(parking.startTime))),
                            DataCell(
                              parking.endTime != null
                                  ? Text(timeFormat.format(parking.endTime!))
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                                'Confirm Stop Parking'),
                                            content: const Text(
                                                'Are you sure you want to stop this parking session?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: const Text('Stop'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          context.read<ParkingBloc>().add(
                                              StopParking(
                                                  parkingId: parking.id));
                                        }
                                      },
                                      child: const Text('Stop'),
                                    ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            } else if (state is ParkingError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const Center(child: Text('No Parkings Available'));
            }
          },
        ),
      ),
      bottomNavigationBar: BottomActionButtons(
        onNew: () async {
          final currentState = context.read<ParkingBloc>().state;
          if (currentState is ParkingLoaded) {
            final ongoingSessions =
                currentState.parkings.where((p) => p.endTime == null).toList();
            final availableVehicles = currentState.vehicles.where((vehicle) {
              return !ongoingSessions
                  .any((session) => session.vehicle.target?.id == vehicle.id);
            }).toList();

            final availableParkingSpaces =
                currentState.parkingSpaces.where((space) {
              return !ongoingSessions.any(
                  (session) => session.parkingSpace.target?.id == space.id);
            }).toList();

            await showDialog(
              context: context,
              builder: (context) => CreateParkingDialog(
                availableVehicles: availableVehicles,
                availableParkingSpaces: availableParkingSpaces,
                onCreate: (newParking) {
                  context.read<ParkingBloc>().add(CreateParking(
                        vehicleId: newParking.vehicle.target!.id.toString(),
                        parkingSpaceId:
                            newParking.parkingSpace.target!.id.toString(),
                      ));
                },
              ),
            );
          }
        },
        onEdit: () async {
          final currentState = context.read<ParkingBloc>().state;
          if (currentState is ParkingLoaded &&
              currentState.selectedParking != null) {
            final selectedParking = currentState.selectedParking!;
            if (selectedParking.endTime != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Cannot edit completed parking sessions.')),
              );
              return;
            }

            final availableParkingSpaces = currentState.availableParkingSpaces;

            await showDialog(
              context: context,
              builder: (context) => EditParkingDialog(
                parking: selectedParking,
                availableParkingSpaces: availableParkingSpaces,
                onEdit: (updatedParking) {
                  context
                      .read<ParkingBloc>()
                      .add(UpdateParking(parking: updatedParking));
                },
              ),
            );
          }
        },
        onDelete: () {
          final currentState = context.read<ParkingBloc>().state;
          if (currentState is ParkingLoaded &&
              currentState.selectedParking != null) {
            final selectedParking = currentState.selectedParking!;

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirm Deletion'),
                content: Text(
                    'Do you want to delete the parking session for vehicle "${selectedParking.vehicle.target?.licensePlate}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ParkingBloc>().add(UpdateParking(
                          parking: selectedParking.copyWith(
                              endTime: DateTime.now())));
                      Navigator.of(context).pop();
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          }
        },
        onReload: () {
          context.read<ParkingBloc>().add(LoadParkings());
        },
      ),
    );
  }
}
