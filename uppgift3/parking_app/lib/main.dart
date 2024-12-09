// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';
import 'package:parking_app/auth_service.dart';
import 'package:provider/provider.dart';

class ParkingView extends StatefulWidget {
  const ParkingView({super.key});

  @override
  State<ParkingView> createState() => _ParkingViewState();
}

class _ParkingViewState extends State<ParkingView> {
  late Future<List<Parking>> ongoingParkings;
  late Future<List<Parking>> allParkings;

  @override
  void initState() {
    super.initState();
    loadParkings();
  }

  void loadParkings() {
    final currentUser = context.read<AuthService>().username;
    ongoingParkings = ParkingRepository().getAll().then((parkings) => parkings
        .where((p) =>
            p.vehicle.target?.owner.target?.name == currentUser &&
            p.endTime == null)
        .toList());
    allParkings = ParkingRepository().getAll().then((parkings) => parkings
        .where((p) => p.vehicle.target?.owner.target?.name == currentUser)
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                loadParkings();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Parking>>(
        future: ongoingParkings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No ongoing parking records found.'));
          }

          final parkings = snapshot.data!;
          return ListView.builder(
            itemCount: parkings.length,
            itemBuilder: (context, index) {
              final parking = parkings[index];
              return ListTile(
                title: Text(
                  'Parking at ${parking.parkingSpace.target?.address ?? 'Unknown'}',
                ),
                subtitle: Text(
                  'Vehicle: ${parking.vehicle.target?.licensePlate ?? 'Unknown'}\n'
                  'Start Time: ${parking.startTime}',
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await ParkingRepository().stop(parking.id);
                    setState(() {
                      loadParkings();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Parking stopped')),
                    );
                  },
                  child: const Text('Stop'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'home',
            onPressed: () {
              context.go('/'); // Navigate to the home page
            },
            child: const Icon(Icons.home),
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: 'history',
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Parking History'),
                    content: FutureBuilder<List<Parking>>(
                      future: allParkings,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No parking history found.');
                        }

                        final parkings = snapshot.data!;
                        return SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: parkings.length,
                            itemBuilder: (context, index) {
                              final parking = parkings[index];
                              return ListTile(
                                title: Text(
                                  'Parking at ${parking.parkingSpace.target?.address ?? 'Unknown'}',
                                ),
                                subtitle: Text(
                                  'Vehicle: ${parking.vehicle.target?.licensePlate ?? 'Unknown'}\n'
                                  'Start Time: ${parking.startTime}\n'
                                  'End Time: ${parking.endTime ?? 'Ongoing'}',
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            label: const Text('History'),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
    );
  }
}
