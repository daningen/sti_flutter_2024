import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart'; // Adjust as needed

class ParkingSpacesView extends StatefulWidget {
  const ParkingSpacesView({super.key, required this.index});

  final int index;

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
        title: const Text("Parking places"),
      ),
      body: FutureBuilder<List<ParkingSpace>>(
        future: getParkingSpaces,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No available parking spaces'));
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                var parkingSpaces = await ParkingSpaceRepository().getAll();
                setState(() {
                  getParkingSpaces = Future.value(parkingSpaces);
                });
              },
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var parkingSpace = snapshot.data![index];
                  return ListTile(
                    title: Text("Address: ${parkingSpace.address}"),
                    subtitle: Text(
                        "Price per hour: ${parkingSpace.pricePerHour} SEK"),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        // Show the edit dialog
                        await _showEditDialog(parkingSpace);
                      },
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          String? address;
          String? price;
          var result = await showDialog<Map<String, String>>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Create Parking Space"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                          hintText: "Enter parking space address"),
                      onChanged: (value) {
                        address = value;
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(
                          hintText: "Enter price per hour"),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        price = value;
                      },
                    ),
                  ],
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
                      if (address != null && price != null) {
                        Navigator.of(context)
                            .pop({"address": address!, "price": price!});
                      }
                    },
                    child: const Text("Create"),
                  ),
                ],
              );
            },
          );

          if (result != null) {
            final newParkingSpace = ParkingSpace(
              address: result["address"]!,
              pricePerHour: int.tryParse(result["price"]!) ?? 0,
            );

            // Add the new parking space to the repository
            await ParkingSpaceRepository().create(newParkingSpace);

            // Refresh the list
            setState(() {
              getParkingSpaces = ParkingSpaceRepository().getAll();
            });
          }
        },
        label: const Text("Create"),
      ),
    );
  }

  Future<void> _showEditDialog(ParkingSpace parkingSpace) async {
    // Pre-fill the form with the current parking space data
    String updatedAddress = parkingSpace.address;
    String updatedPrice = parkingSpace.pricePerHour.toString();

    var result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Parking Space"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: "Edit address"),
                controller: TextEditingController(text: parkingSpace.address),
                onChanged: (value) {
                  updatedAddress = value;
                },
              ),
              TextField(
                decoration:
                    const InputDecoration(hintText: "Edit price per hour"),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                    text: parkingSpace.pricePerHour.toString()),
                onChanged: (value) {
                  updatedPrice = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel and close dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  "address": updatedAddress,
                  "price": updatedPrice,
                }); // Submit updated data
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      try {
        // Construct an updated ParkingSpace object
        final updatedParkingSpace = ParkingSpace(
          id: parkingSpace.id, // Keep the original ID
          address: result["address"]!,
          pricePerHour: int.parse(result["price"]!),
        );

        // Call repository to update the parking space in the database
        await ParkingSpaceRepository().update(
          updatedParkingSpace.id,
          updatedParkingSpace,
        );

        // Refresh the list to show the updated data
        setState(() {
          getParkingSpaces = ParkingSpaceRepository().getAll();
        });

        // Notify the user of success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Parking space updated successfully.")),
          );
        }
      } catch (e) {
        // Handle update errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update parking space: $e")),
          );
        }
      }
    }
  }
}
