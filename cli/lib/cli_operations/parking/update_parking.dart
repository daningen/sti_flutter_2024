import 'dart:convert';
import 'dart:io';
import 'package:cli/config/config.dart';
import 'package:cli/models/vehicle.dart';
import 'package:cli/models/parking.dart';
import 'package:http/http.dart' as http;

Future<void> updateParking() async {
  print("Ange registreringsnummer för att uppdatera parkeringen:");
  String licensePlate = stdin.readLineSync()!;

  try {
    // Step 1: Fetch vehicle by license plate
    final vehiclesUrl = Uri.parse('$vehiclesEndpoint');
    final vehiclesResponse = await http.get(vehiclesUrl);

    if (vehiclesResponse.statusCode == 200) {
      List<dynamic> vehiclesList = jsonDecode(vehiclesResponse.body);

      // Find the vehicle by license plate
      var vehicleJson = vehiclesList.firstWhere(
        (v) => v['licensePlate'] == licensePlate,
        orElse: () => null,
      );

      if (vehicleJson != null) {
        Vehicle vehicle = Vehicle.fromJson(vehicleJson);

        // Step 2: Fetch parking session by vehicle ID
        final parkingUrl =
            Uri.parse('$parkingsEndpoint?vehicleId=${vehicle.id}');
        final parkingResponse = await http.get(parkingUrl);

        if (parkingResponse.statusCode == 200) {
          List<dynamic> parkingList = jsonDecode(parkingResponse.body);

          if (parkingList.isNotEmpty) {
            // Get the first parking session for the vehicle
            Map<String, dynamic> parkingJson = parkingList.first;
            Parking parking = Parking.fromJson(parkingJson);

            // Prompt for updated information
            print("Ange ny parkeringsplatsens adress:");
            String newParkingSpaceAddress = stdin.readLineSync()!;

            print("Ange nytt pris per timme:");
            int newPricePerHour = int.parse(stdin.readLineSync()!);

            // Update the parking space information
            final updatedParkingJson = {
              'vehicle': parking.vehicle.toJson(),
              'parkingSpace': {
                'id': parking
                    .parkingSpace.id, // Maintain the same parking space ID
                'address': newParkingSpaceAddress,
                'pricePerHour': newPricePerHour,
              },
              'startTime': parking.startTime.toIso8601String(),
              'endTime': parking.endTime?.toIso8601String(),
            };

            // Step 3: Send PUT request to update the parking
            final putUrl = Uri.parse('$parkingsEndpoint/${parking.id}');
            final putResponse = await http.put(
              putUrl,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(updatedParkingJson),
            );

            print(
                "PUT response received with status code: ${putResponse.statusCode}");
            if (putResponse.statusCode == 200) {
              print('Parkeringen uppdaterad.');
            } else {
              print(
                  'Misslyckades att uppdatera parkeringen: ${putResponse.body}');
            }
          } else {
            print(
                'Ingen parkering hittades för fordonet med ID: ${vehicle.id}');
          }
        } else {
          print('Ingen parkering hittades för fordonet.');
        }
      } else {
        print('Ingen fordon hittades med registreringsnummer: $licensePlate');
      }
    } else {
      print('Misslyckades att hämta fordon.');
    }
  } catch (e) {
    print("Error updating parking: $e");
  }
}
