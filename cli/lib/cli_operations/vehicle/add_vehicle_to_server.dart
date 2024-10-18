import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cli/config/config.dart';
import 'package:cli/utils/ssn_validator.dart';

Future<void> addVehicleToServer() async {
  print("Entering addVehicleToServer");

  while (true) {
    print("Ange regnummer:");
    String licensePlate = stdin.readLineSync()!;

    print("väntar med att kolla om fordon redan finns.");
//
//     final existingVehicleUrl = Uri.parse('$vehiclesEndpoint/$licensePlate');
//     print("Sending GET request to $existingVehicleUrl");

//     final existingResponse = await http.get(existingVehicleUrl);
//     print("Received response with status code: ${existingResponse.statusCode}");

//     if (existingResponse.statusCode == 200) {
//       print("Fordon är redan upplagt. Försök igen med ett nytt ID.");
//       break; // Exit the loop if the vehicle already exists
//     } else {
    print("Proceeding with adding a new vehicle...");
    print("Ange typ av fordon, ex bil, motorcyckel:");
    String vehicleType = stdin.readLineSync()!;

    print("Ange ägare av fordon:");
    String name = stdin.readLineSync()!;

    String ssn;
    do {
      print("personnummer  ddmmår:");
      ssn = stdin.readLineSync()!;
      if (!ssnFormat.hasMatch(ssn)) {
        print("Ogiltigt personnummer (YYMMDD). Försök igen.");
      }
    } while (!ssnFormat.hasMatch(ssn));

    // skap json format av person
    final personJson = {
      'name': name,
      'ssn': ssn,
    };

    // skap json format av fordon
    final vehicleJson = {
      'licensePlate': licensePlate,
      'vehicleType': vehicleType,
      'owner': personJson,
    };

    print("Sending POST request to add vehicle...");
    // Send a POST request to add the vehicle to the server
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
      break;
    } else {
      print('Failed to add vehicle: ${response.body}');
      break;
    }
//     }
  }

  print("Exiting addVehicleToServer");
}
