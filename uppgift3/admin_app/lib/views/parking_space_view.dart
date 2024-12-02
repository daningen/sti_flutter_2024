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
                        "Price per hour : ${parkingSpace.pricePerHour} SEK"),
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
                title: const Text("create"),
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
                          hintText: "Ange pris per timme"),
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
                    child: const Text("create"),
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
        label: const Text("create"),
      ),
    );
  }
}
