// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/bloc/parkings/parking_bloc.dart';
import 'package:shared/bloc/parkings/parking_event.dart';
import 'package:shared/bloc/parkings/parking_state.dart';

class ParkingView extends StatelessWidget {
  const ParkingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Management'),
        actions: [
          BlocBuilder<ParkingBloc, ParkingState>(
            builder: (context, state) {
              if (state is ParkingLoaded) {
                return IconButton(
                  icon: Icon(state.isFilteringActive ? Icons.filter_list : Icons.filter_alt_off),
                  tooltip: state.isFilteringActive ? 'Show All Parkings' : 'Show Active Parkings',
                  onPressed: () {
                    context.read<ParkingBloc>().add(
                      LoadParkings(showActiveOnly: !state.isFilteringActive),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Implement logout logic
              Navigator.of(context).pushNamed('/start');
            },
          ),
        ],
      ),
      body: BlocBuilder<ParkingBloc, ParkingState>(
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
                    headingRowColor: MaterialStateProperty.resolveWith(
                      (states) => Theme.of(context).brightness == Brightness.dark
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
                          context.read<ParkingBloc>().add(
                            SelectParking(selectedParking: selected == true ? parking : null),
                          );
                        },
                        color: MaterialStateProperty.resolveWith(
                          (states) => isSelected ? Colors.blue[100] : Colors.transparent,
                        ),
                        cells: [
                          DataCell(Text(parking.vehicle.target?.licensePlate ?? 'N/A')),
                          DataCell(Text(parking.parkingSpace.target?.address ?? 'N/A')),
                          DataCell(Text(parking.startTime.toIso8601String())),
                          DataCell(
                            parking.endTime != null
                                ? Text(parking.endTime!.toIso8601String())
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () {
                                      context.read<ParkingBloc>().add(StopParking(parkingId: parking.id));
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add logic to create a new parking
        },
        tooltip: 'Add Parking',
        child: const Icon(Icons.add),
      ),
    );
  }
}
