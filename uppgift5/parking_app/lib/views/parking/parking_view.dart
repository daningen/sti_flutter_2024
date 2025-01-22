import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_app/views/parking/dialog/create_parking_dialog.dart';
import 'package:shared/bloc/parkings/parking_bloc.dart';
import 'package:shared/bloc/parkings/parking_event.dart';
import 'package:shared/bloc/parkings/parking_state.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/providers/theme_notifier.dart';
import 'package:parking_app/views/parking/parking_navigation_bar.dart';

class ParkingView extends StatelessWidget {
  const ParkingView({super.key});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('yyyy-MM-dd HH:mm');
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Management'),
        actions: [
          BlocBuilder<ParkingBloc, ParkingState>(
            builder: (context, state) {
              if (state is ParkingLoaded) {
                return Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        state.isFilteringActive
                            ? Icons.filter_list_alt
                            : Icons.filter_list,
                      ),
                      tooltip: state.isFilteringActive
                          ? 'Show Active Parkings'
                          : 'Show All Parkings',
                      onPressed: () {
                        context.read<ParkingBloc>().add(
                              LoadParkings(showActiveOnly: !state.isFilteringActive),
                            );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        themeNotifier.themeMode == ThemeMode.light
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                      onPressed: themeNotifier.toggleTheme,
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
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

            return ListView.builder(
              itemCount: parkings.length,
              itemBuilder: (context, index) {
                final parking = parkings[index];
                final parkingSpace = parking.parkingSpace;
                final vehicle = parking.vehicle;

                return Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parking at: ${parkingSpace?.address ?? 'N/A'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Vehicle: ${vehicle?.licensePlate ?? 'N/A'}',
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Start Time: ${timeFormat.format(parking.startTime)}',
                      ),
                      const SizedBox(height: 4.0),
                      parking.endTime != null
                          ? Text(
                              'End Time: ${timeFormat.format(parking.endTime!)}',
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 243, 112, 102),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                context.read<ParkingBloc>().add(
                                      StopParking(parkingId: parking.id),
                                    );
                              },
                              child: const Text('Stop Parking'),
                            ),
                    ],
                  ),
                );
              },
            );
          } else if (state is ParkingError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('No Parkings Available'));
          }
        },
      ),
      bottomNavigationBar: ParkingNavigationBar(
        onHomePressed: () => context.go('/'),
        onShowAllParkings: () {
          context.read<ParkingBloc>().add(LoadParkings(showActiveOnly: false));
        },
        onShowActiveParkings: () {
          context.read<ParkingBloc>().add(LoadParkings(showActiveOnly: true));
        },
        onAddParkingPressed: () async {
          final currentState = context.read<ParkingBloc>().state;

          if (currentState is ParkingLoaded) {
            final availableVehicles = currentState.availableVehicles;
            final availableParkingSpaces = currentState.availableParkingSpaces;

            if (availableVehicles.isEmpty || availableParkingSpaces.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No available vehicles or parking spaces.'),
                ),
              );
              return;
            }

            await showDialog(
              context: context,
              builder: (context) => CreateParkingDialog(
                availableVehicles: availableVehicles,
                availableParkingSpaces: availableParkingSpaces,
                onCreate: (newParking) {
                  context.read<ParkingBloc>().add(
                        CreateParking(
                          vehicleId: newParking.vehicle?.id ?? '',
                          parkingSpaceId: newParking.parkingSpace?.id ?? '',
                        ),
                      );
                },
              ),
            );
          }
        },
        onLogoutPressed: () {
          debugPrint('Logout pressed');
          context.go('/login');
        },
      ),
    );
  }
}
