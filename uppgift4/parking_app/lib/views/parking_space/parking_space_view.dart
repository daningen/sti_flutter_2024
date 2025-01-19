import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:shared/bloc/parking_spaces/parking_space_bloc.dart';
import 'package:shared/bloc/parking_spaces/parking_space_event.dart';
import 'package:shared/bloc/parking_spaces/parking_space_state.dart';

import 'parking_space_navigation_bar.dart';

class ParkingSpacesView extends StatelessWidget {
  const ParkingSpacesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Parking Spaces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ParkingSpaceBloc>().add(LoadParkingSpaces());
            },
          ),
        ],
      ),
      body: BlocBuilder<ParkingSpaceBloc, ParkingSpaceState>(
        builder: (context, state) {
          if (state is ParkingSpaceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ParkingSpaceError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ParkingSpaceLoaded) {
            if (state.parkingSpaces.isEmpty) {
              return const Center(child: Text('No parking spaces found'));
            }

            final parkingSpaces = state.parkingSpaces;
            return ListView.builder(
              itemCount: parkingSpaces.length,
              itemBuilder: (context, index) {
                final parkingSpace = parkingSpaces[index];
                return ListTile(
                  title: Text(parkingSpace.address),
                  subtitle: Text(
                      'Price: ${NumberFormat.currency(locale: 'sv_SE', symbol: 'SEK', decimalDigits: 0).format(parkingSpace.pricePerHour)} / hour'),
                  trailing: IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () {
                      // Add action for more details if needed
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Unexpected state'));
          }
        },
      ),
      bottomNavigationBar: ParkingSpacesNavigationBar(
        onHomePressed: () {
          context.go('/'); // Navigate to home
        },
        onReloadPressed: () {
          context.read<ParkingSpaceBloc>().add(LoadParkingSpaces());
        },
        onLogoutPressed: () {
          context.go('/login'); // Navigate to login
        },
      ),
    );
  }
}
