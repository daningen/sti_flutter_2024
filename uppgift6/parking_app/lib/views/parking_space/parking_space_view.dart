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
        title: const Text('Parking Spaces'),
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
                    'Price: ${NumberFormat.currency(
                      locale: 'sv_SE',
                      symbol: 'SEK',
                      decimalDigits: 0,
                    ).format(parkingSpace.pricePerHour)} / hour',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        parkingSpace.isAvailable
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: parkingSpace.isAvailable
                            ? Colors.green
                            : Colors.red,
                      ),
                      // IconButton(
                      //   icon: const Icon(Icons.info),
                      //   onPressed: () {
                      //     // Future action can be added here (e.g., details page)
                      //   },
                      // ),
                    ],
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
          context.go('/login');
        },
        onAddParkingSpace: () {
          _showAddParkingSpaceDialog(context);
        },
      ),
    );
  }

  void _showAddParkingSpaceDialog(BuildContext context) {
    final addressController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Parking Space'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter an address' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price per Hour'),
                validator: (value) {
                  final price = int.tryParse(value ?? '');
                  return (price == null || price <= 0)
                      ? 'Enter a valid price'
                      : null;
                },
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
                final address = addressController.text.trim();
                final price = int.parse(priceController.text.trim());

                context.read<ParkingSpaceBloc>().add(
                      CreateParkingSpace(
                        address: address,
                        pricePerHour: price,
                      ),
                    );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
