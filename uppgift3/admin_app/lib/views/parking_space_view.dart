import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

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
      body: SafeArea(
        child: FutureBuilder<List<ParkingSpace>>(
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
                  padding:
                      const EdgeInsets.only(bottom: 80), // Add bottom padding
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var parkingSpace = snapshot.data![index];
                    return ListTile(
                      title: Text("Address: ${parkingSpace.address}"),
                      subtitle: Text(
                          "Price per hour: ${parkingSpace.pricePerHour} SEK"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              await _showEditDialog(parkingSpace);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              bool? confirmDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Delete Parking Space"),
                                    content: const Text(
                                        "Are you sure you want to delete this parking space?"),
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
                                await _deleteParkingSpace(parkingSpace);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
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

            await ParkingSpaceRepository().create(newParkingSpace);

            setState(() {
              getParkingSpaces = ParkingSpaceRepository().getAll();
            });
          }
        },
        label: const Text("Create"),
      ),
    );
  }

  Future<void> _deleteParkingSpace(ParkingSpace parkingSpace) async {
    try {
      await ParkingSpaceRepository().delete(parkingSpace.id);
      setState(() {
        getParkingSpaces = ParkingSpaceRepository().getAll();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Parking space deleted successfully.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete parking space: $e")),
        );
      }
    }
  }

  Future<void> _showEditDialog(ParkingSpace parkingSpace) async {
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
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  "address": updatedAddress,
                  "price": updatedPrice,
                });
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      try {
        final updatedParkingSpace = ParkingSpace(
          id: parkingSpace.id,
          address: result["address"]!,
          pricePerHour: int.parse(result["price"]!),
        );

        await ParkingSpaceRepository().update(
          updatedParkingSpace.id,
          updatedParkingSpace,
        );

        setState(() {
          getParkingSpaces = ParkingSpaceRepository().getAll();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Parking space updated successfully.")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update parking space: $e")),
          );
        }
      }
    }
  }
}
