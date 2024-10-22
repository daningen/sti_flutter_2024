import 'dart:convert';
import 'dart:io';
import 'package:cli/config/config.dart';
import 'package:cli/models/parking.dart';
import 'package:http/http.dart' as http;

Future<void> updateParking() async {
  print("Ange registreringsnummer för att uppdatera parkeringen:");
  String licensePlate = stdin.readLineSync()!;

  try {
    // Step 1: Fetch parking by vehicle's license plate from the parking repository
    final parkingUrl =
        Uri.parse('$parkingsEndpoint?licensePlate=$licensePlate');
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
            'id': parking.parkingSpace.id, // Keep the same parking space ID
            'address': newParkingSpaceAddress,
            'pricePerHour': newPricePerHour,
          },
          'startTime': parking.startTime.toIso8601String(),
          'endTime': parking.endTime?.toIso8601String(),
        };

        // Step 2: Send PUT request to update the parking by ID
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
          print('Misslyckades att uppdatera parkeringen: ${putResponse.body}');
        }
      } else {
        print(
            'Ingen parkering hittades för registreringsnummer: $licensePlate');
      }
    } else {
      print('Ingen parkering hittades för registreringsnummer: $licensePlate');
    }
  } catch (e) {
    print("Error updating parking: $e");
  }
}
