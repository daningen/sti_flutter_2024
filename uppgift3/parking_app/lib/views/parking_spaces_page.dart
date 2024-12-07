import 'package:flutter/material.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

class ParkingSpacesView extends StatefulWidget {
  const ParkingSpacesView({super.key});

  @override
  State<ParkingSpacesView> createState() => _ParkingSpacesViewState();
}

class _ParkingSpacesViewState extends State<ParkingSpacesView> {
  Future<List<ParkingSpace>> getParkingSpaces =
      ParkingSpaceRepository().getAll();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Parking Spaces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                getParkingSpaces = ParkingSpaceRepository().getAll();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ParkingSpace>>(
        future: getParkingSpaces,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No parking spaces found'));
          }

          final parkingSpaces = snapshot.data!;
          return ListView.builder(
            itemCount: parkingSpaces.length,
            itemBuilder: (context, index) {
              final parkingSpace = parkingSpaces[index];
              return ListTile(
                title: Text(parkingSpace.address),
                subtitle: Text('Price: \$${parkingSpace.pricePerHour}/hour'),
                trailing: IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () {
                    // Add action for more details if needed
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home',
        onPressed: () {
          // Navigator.of(context).pop(); // Go back to home doesnt work
          context.go('/'); // Navigate back to home - works
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}
