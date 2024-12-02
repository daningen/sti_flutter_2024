import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart'; // Adjust as needed

class ParkingView extends StatefulWidget {
  const ParkingView({super.key});

  @override
  State<ParkingView> createState() => _ParkingViewState();
}

class _ParkingViewState extends State<ParkingView> {
  Future<List<Parking>> getParkings = ParkingRepository().getAll();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List of Parkings"),
      ),
      body: FutureBuilder<List<Parking>>(
        future: getParkings,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return RefreshIndicator(
              onRefresh: () async {
                var parkings = await ParkingRepository().getAll();
                setState(() {
                  getParkings = Future.value(parkings);
                });
              },
              child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var parking = snapshot.data![index];
                    return ListTile(
                      title: Text(parking.vehicle.target?.licensePlate ??
                          "Unknown Vehicle"),
                    );
                  }),
            );
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
