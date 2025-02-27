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
import 'package:shared/shared.dart';
import 'package:shared/bloc/auth/auth_firebase_bloc.dart';

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
          // Filter and Theme Toggle Buttons
          BlocBuilder<ParkingBloc, ParkingState>(
            builder: (context, state) {
              debugPrint(
                  "ParkingBlocBuilder (AppBar) called. State: ${state.runtimeType}"); // When ParkingBloc state changes in the AppBar
              if (state is ParkingLoaded) {
                return Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        state.filter == ParkingFilter.active
                            ? Icons.filter_list_alt
                            : Icons.filter_list,
                      ),
                      tooltip: state.filter == ParkingFilter.active
                          ? 'Show Inactive Parkings'
                          : 'Show Active Parkings',
                      onPressed: () {
                        // Toggle Parking Filter
                        debugPrint(
                            "Filter button pressed. Current Filter: ${state.filter}");
                        final newFilter = state.filter == ParkingFilter.active
                            ? ParkingFilter.inactive
                            : ParkingFilter.active;
                        context
                            .read<ParkingBloc>()
                            .add(ChangeFilter(newFilter));
                        debugPrint("New Filter: $newFilter");
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
        buildWhen: (previous, current) {
          // Optimize Rebuilds: Only rebuild if parkings list changes
          if (previous is ParkingLoaded && current is ParkingLoaded) {
            return previous.parkings != current.parkings;
          }
          return true; // Rebuild for other state changes (Loading, Error, etc.)
        },
        builder: (context, state) {
          // Build UI based on ParkingBloc state
          if (state is ParkingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ParkingLoaded) {
            final parkings = state.parkings;
            debugPrint(
                "ParkingLoaded state. parkings list length: ${state.parkings.length}");

            return ListView.builder(
              itemCount: parkings.length,
              itemBuilder: (context, index) {
                final parking = parkings[index];
                final parkingSpace = parking.parkingSpace;
                final vehicle = parking.vehicle;

                return ParkingListItem(
                  // Extract to separate widget
                  parking: parking,
                  parkingSpace: parkingSpace,
                  vehicle: vehicle,
                  timeFormat: timeFormat,
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
        onShowAllParkings: () => context
            .read<ParkingBloc>()
            .add(LoadParkings(filter: ParkingFilter.all)),
        onShowActiveParkings: () => context
            .read<ParkingBloc>()
            .add(LoadParkings(filter: ParkingFilter.active)),
        onAddParkingPressed: () async {
          final parkingState = context.read<ParkingBloc>().state;
          final authState = context.read<AuthFirebaseBloc>().state;

          if (parkingState is ParkingLoaded && authState is AuthAuthenticated) {
            final authUser = authState.user;
            final allVehicles = parkingState
                .availableVehicles; // Use all available vehicles from the state
            final availableParkingSpaces = parkingState.availableParkingSpaces;

            // Filter vehicles based on the logged-in user
            final userVehicles = allVehicles
                .where((vehicle) => vehicle.ownerAuthId == authUser.uid)
                .toList();

            debugPrint(
                "[ParkingView]: Available Vehicles Count: ${userVehicles.length}");
            debugPrint(
                "[ParkingView]: Available Parking Spaces Count: ${availableParkingSpaces.length}");

            if (userVehicles.isEmpty || availableParkingSpaces.isEmpty) {
              // Show Snackbar if no vehicles or parking spaces are available
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('No available vehicles or parking spaces for you.'),
                ),
              );
              return;
            }

            // Show CreateParkingDialog with filtered vehicles
            await showDialog(
              context: context,
              builder: (context) => CreateParkingDialog(
                availableVehicles: userVehicles, // Pass filtered vehicles
                availableParkingSpaces: availableParkingSpaces,
                onCreate: (newParking) {
                  context.read<ParkingBloc>().add(CreateParking(newParking));
                },
              ),
            );
          } else if (authState is AuthUnauthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You must be logged in to create a parking.'),
              ),
            );
          }
        },
        onLogoutPressed: () {
          Navigator.of(context).pop();
          context.read<AuthFirebaseBloc>().add(LogoutRequested());
          context.go('/login');
        },
      ),
    );
  }
}

class ParkingListItem extends StatelessWidget {
  final Parking parking;
  final ParkingSpace? parkingSpace;
  final Vehicle? vehicle;
  final DateFormat timeFormat;

  const ParkingListItem({
    super.key,
    required this.parking,
    required this.parkingSpace,
    required this.vehicle,
    required this.timeFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        // color: (parking.endTime == null ||
        //         parking.endTime!.isAfter(DateTime.now().toUtc()))
        //     ? const Color.fromARGB(255, 239, 236, 232) // Active Parking Color
        //     : const Color.fromARGB(
        //         255, 232, 237, 232), // Inactive Parking Color
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // Row for "Parking at" and the Prolong button
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Align items to start and end
            children: [
              Text(
                'Parking at: ${parkingSpace?.address ?? 'N/A'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  debugPrint("[ParkingView] Prolong Parking button pressed");

                  debugPrint(
                      "[ParkingView] Parking object: $parking"); // Log the entire parking object
                  final parkingId = parking.id;
                  debugPrint("[ParkingView] Parking ID to prolong: $parkingId");

                  if (parking.endTime != null &&
                      parking.endTime!.isAfter(DateTime.now().toUtc())) {
                    // Only check endTime
                    context
                        .read<ParkingBloc>()
                        .add(ProlongParking(parkingId: parkingId));
                    debugPrint(
                        "[ParkingView] ProlongParking event dispatched for ID: $parkingId");

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Parking prolonged successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    debugPrint(
                        "[ParkingView] Parking session is not active or endTime is null");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'This parking session is not active or data is missing.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (parking.endTime == null ||
                          parking.endTime!.isAfter(DateTime.now().toUtc()))
                      ? Colors.red // Green background if available
                      : Colors.green, // Red background if unavailable
                  foregroundColor: Colors.white, // Always white foreground
                  padding: const EdgeInsets.all(8.0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Icon(
                  parking.endTime == null ||
                          parking.endTime!.isAfter(DateTime.now().toUtc())
                      ? Icons.directions_car
                      : Icons.local_parking,
                  color: Colors.white, // White icon if available
                  size: 20,
                ),
              )
            ],
          ),
          const SizedBox(height: 4.0), // Spacing below the row
          Text('Vehicle: ${vehicle?.licensePlate ?? 'N/A'}'),
          const SizedBox(height: 4.0),
          Text('Start Time: ${timeFormat.format(parking.startTime)}'),
          Text(
            'End Time: ${parking.endTime != null ? timeFormat.format(parking.endTime!) : 'N/A'}',
          ),
          const SizedBox(height: 4.0),
          if (parking.endTime == null ||
              parking.endTime!.isAfter(DateTime.now().toUtc()))
            if (parking.endTime == null ||
                parking.endTime!.isAfter(DateTime.now().toUtc()))
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 243, 112, 102),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  context
                      .read<ParkingBloc>()
                      .add(StopParking(parkingId: parking.id));
                },
                child: const Text('Stop Parking'),
              ),
        ],
      ),
    );
  }
}
