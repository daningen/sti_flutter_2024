// ignore_for_file: use_build_context_synchronously

import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ParkingView extends StatefulWidget {
  const ParkingView({super.key});

  @override
  State<ParkingView> createState() => _ParkingViewState();
}

class _ParkingViewState extends State<ParkingView> {
  Future<List<Parking>> getParkings = ParkingRepository().getAll();
  bool showActiveOnly = false; // Toggle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parking Management"),
      ),
      body: Column(
        children: [
          // Buttons for filtering
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        showActiveOnly = false; // Show all parkings
                        getParkings = ParkingRepository().getAll();
                      });
                    },
                    icon: const Icon(Icons.list),
                    label: const Text("All Parkings"),
                  ),
                ),
                const SizedBox(width: 8), // Add spacing between buttons
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        showActiveOnly = true; // Show active parkings
                        getParkings = ParkingRepository().getAll().then(
                              (parkings) => parkings
                                  .where((p) => p.endTime == null)
                                  .toList(),
                            );
                      });
                    },
                    icon: const Icon(Icons.filter_alt),
                    label: const Text("Active Parkings"),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Parking>>(
              future: getParkings,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No parkings available'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    var parkings = await ParkingRepository().getAll();
                    setState(() {
                      if (showActiveOnly) {
                        getParkings = Future.value(
                            parkings.where((p) => p.endTime == null).toList());
                      } else {
                        getParkings = Future.value(parkings);
                      }
                    });
                  },
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var parking = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(
                            "Vehicle: ${parking.vehicle.target?.licensePlate ?? 'Unknown'}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Parking Space: ${parking.parkingSpace.target?.address ?? 'Unknown'}"),
                              Text("Start Time: ${parking.startTime}"),
                              Text("End Time: ${parking.endTime ?? 'Ongoing'}"),
                              Text("Duration: ${_calculateDuration(parking)}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  await _showEditDialog(parking);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  bool? confirmDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Delete Parking"),
                                        content: const Text(
                                            "Are you sure you want to delete this parking?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmDelete == true) {
                                    await _deleteParking(parking);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDuration(Parking parking) {
    final startTime = parking.startTime;
    final endTime = parking.endTime ?? DateTime.now();

    final duration = endTime.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return "$hours hours, $minutes minutes";
  }

  Future<void> _showEditDialog(Parking parking) async {
    String updatedLicensePlate =
        parking.vehicle.target?.licensePlate ?? "Unknown Vehicle";

    var result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Parking"),
          content: TextField(
            decoration: const InputDecoration(hintText: "Edit License Plate"),
            controller: TextEditingController(
                text: parking.vehicle.target?.licensePlate),
            onChanged: (value) {
              updatedLicensePlate = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(updatedLicensePlate);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      try {
        final updatedVehicle = parking.vehicle.target!;
        updatedVehicle.licensePlate = result;

        // Call repository to update the parking
        await ParkingRepository().update(parking.id, parking);

        setState(() {
          getParkings = ParkingRepository().getAll();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Parking updated successfully.")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update parking: $e")),
        );
      }
    }
  }

  Future<void> _deleteParking(Parking parking) async {
    try {
      // Call repository to delete the parking
      await ParkingRepository().delete(parking.id);

      setState(() {
        getParkings = ParkingRepository().getAll();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Parking deleted successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete parking: $e")),
      );
    }
  }
}
