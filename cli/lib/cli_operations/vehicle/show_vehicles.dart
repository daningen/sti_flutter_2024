import 'dart:convert';
import 'package:cli/config/config.dart';
import 'package:cli/models/vehicle.dart';
import 'package:http/http.dart' as http;

Future<void> showVehicles() async {
  print("Fetching vehicles from server...");

  try {
    final url =
        Uri.parse(vehiclesEndpoint); // The same endpoint used in addVehicle
    final response = await http.get(url);

    // Check if the response is successful (HTTP status code 200)
    if (response.statusCode == 200) {
      List<dynamic> vehiclesJson = jsonDecode(response.body);

      if (vehiclesJson.isEmpty) {
        print("Inga fordon registrerade.");
      } else {
        print("Lista över alla fordon:");
        for (var vehicleJson in vehiclesJson) {
          Vehicle vehicle = Vehicle.fromJson(vehicleJson);
          // Display the vehicle id along with other information
          print(
              "ID: ${vehicle.id}, Registreringsnummer: ${vehicle.licensePlate}, Typ: ${vehicle.vehicleType}, Ägare: ${vehicle.owner.name}");
          print("did i get the id?");
        }
      }
    } else {
      print("Failed to fetch vehicles: ${response.body}");
    }
  } catch (e) {
    print("Error fetching vehicles: $e");
  }
}
