import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cli/cli_operations/vehicle/collect_vehicle_information.dart';
import 'package:cli/config/config.dart';

Future<void> addVehicleToServer2() async {
  print("Entering addVehicleToServer");

  // anropar formulär för att samla info
  Map<String, String> vehicleInput = await collectVehicleInput();

  // print("har jag skapat min map med ifyllda värden?");
  // skapa vehicle JSON objekten
  final personJson = {
    'name': vehicleInput['name'],
    'ssn': vehicleInput['ssn'],
  };

  final vehicleJson = {
    'licensePlate': vehicleInput['licensePlate'],
    'vehicleType': vehicleInput['vehicleType'],
    'owner': personJson,
  };

  print("Sending POST request to add vehicle...");

  try {
    // POST request för att lägga till fordon på server
    final url = Uri.parse(vehiclesEndpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vehicleJson),
    );

    print("POST response received with status code: ${response.statusCode}");
    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      print('Server Response: ${responseBody['message']}');
      print('Added Vehicle Details: ${responseBody['vehicle']}');
      print('Total Vehicles on Server: ${responseBody['totalVehicles']}');
    } else {
      print('Failed to add vehicle: ${response.body}');
    }
  } catch (e) {
    print('Error while adding vehicle: $e');
  }

  print("Exiting addVehicleToServer");
}
