import 'package:admin_app/bloc/parking_bloc.dart';
import 'package:admin_app/bloc/parking_event.dart';
import 'package:admin_app/bloc/parking_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../widgets/app_bar_actions.dart';
import '../widgets/bottom_action_buttons.dart.dart';

class ParkingView extends StatelessWidget {
  const ParkingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Dispatch the initial LoadParkings event when the ParkingView is built
    context.read<ParkingBloc>().add(LoadParkings());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking'),
        actions: const [AppBarActions()],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<ParkingBloc>().add(LoadParkings());
                },
                child: const Text('All Parkings'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context
                      .read<ParkingBloc>()
                      .add(LoadParkings(showActiveOnly: true));
                },
                child: const Text('Active Parkings'),
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<ParkingBloc, ParkingState>(
              builder: (context, state) {
                if (state is ParkingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ParkingError) {
                  return Center(child: Text(state.message));
                }
                if (state is ParkingLoaded) {
                  final parkings = state.parkings;
                  return SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('VEHICLE')),
                        DataColumn(label: Text('ADDRESS')),
                        DataColumn(label: Text('START TIME')),
                        DataColumn(label: Text('END TIME')),
                      ],
                      rows: parkings.map((parking) {
                        return DataRow(cells: [
                          DataCell(Text(
                              parking.vehicle.target?.licensePlate ?? 'N/A')),
                          DataCell(Text(
                              parking.parkingSpace.target?.address ?? 'N/A')),
                          DataCell(Text(DateFormat('yyyy-MM-dd HH:mm')
                              .format(parking.startTime))),
                          DataCell(
                            parking.endTime != null
                                ? Text(DateFormat('yyyy-MM-dd HH:mm')
                                    .format(parking.endTime!))
                                : ElevatedButton(
                                    onPressed: () {
                                      context.read<ParkingBloc>().add(
                                          StopParking(parkingId: parking.id));
                                    },
                                    child: const Text('Stop'),
                                  ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          BottomActionButtons(
            onNew: () => _showCreateParkingDialog(context),
            onEdit: () {},
            onDelete: () {},
            onReload: () => context.read<ParkingBloc>().add(LoadParkings()),
          ),
        ],
      ),
    );
  }

  void _showCreateParkingDialog(BuildContext context) {
    final vehicleController = TextEditingController();
    final parkingSpaceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Parking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vehicleController,
                decoration: const InputDecoration(labelText: 'Vehicle ID'),
              ),
              TextField(
                controller: parkingSpaceController,
                decoration:
                    const InputDecoration(labelText: 'Parking Space ID'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final vehicleId = vehicleController.text;
                final parkingSpaceId = parkingSpaceController.text;

                if (vehicleId.isNotEmpty && parkingSpaceId.isNotEmpty) {
                  context.read<ParkingBloc>().add(
                        CreateParking(
                          vehicleId: vehicleId,
                          parkingSpaceId: parkingSpaceId,
                        ),
                      );
                  Navigator.pop(context); // Close the dialog
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
