import 'dart:convert';
import 'dart:io';
import 'package:cli/config/config.dart';
import 'package:cli/models/parking.dart';
import 'package:http/http.dart' as http;

Future<void> stopParking() async {
  print("Ange registreringsnummer för att avsluta parkeringen:");
  String licensePlate = stdin.readLineSync()!;

  try {
    // Fetch parking by license plate
    final url = Uri.parse('$parkingsEndpoint?licensePlate=$licensePlate');
    final getResponse = await http.get(url);

    if (getResponse.statusCode == 200) {
      List<dynamic> parkingList = jsonDecode(getResponse.body);

      if (parkingList.isNotEmpty) {
        // Fetch the first parking record
        Map<String, dynamic> parkingJson = parkingList.first;
        Parking parking = Parking.fromJson(parkingJson);

        // End the parking session
        parking.endParkingSession();

        // Convert updated parking object to JSON
        final updatedParkingJson = parking.toJson();

        // Send PUT request to update parking with end time
        final putUrl = Uri.parse('$parkingsEndpoint/${parking.id}');
        final putResponse = await http.put(
          putUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updatedParkingJson),
        );

        print(
            "PUT response received with status code: ${putResponse.statusCode}");
        if (putResponse.statusCode == 200) {
          print('Parkeringen avslutad.');
        } else {
          print('Misslyckades att avsluta parkeringen: ${putResponse.body}');
        }
      } else {
        print(
            'Ingen parkering hittades för registreringsnummer: $licensePlate');
      }
    } else {
      print('Ingen parkering hittades för registreringsnummer: $licensePlate');
    }
  } catch (e) {
    print("Error stopping parking: $e");
  }
}
