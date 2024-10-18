import 'package:cli/config/config.dart';
import 'package:cli/utils/ssn_validator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

Future<void> addVehicleTest() async {
  while (true) {
    print("Ange regnummer:");
    String licensePlate = stdin.readLineSync()!;

    // Check om fordon redan finns
    final existingVehicleUrl = Uri.parse('$vehiclesEndpoint/$licensePlate');
    final existingResponse = await http.get(existingVehicleUrl);

    if (existingResponse.statusCode == 200) {
      print("Fordon är redan upplagt. Försök igen med ett nytt ID.");
    } else {
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

      // skapa json format av person
      final personJson = {
        'name': name,
        'ssn': ssn,
      };

      // skapa json format av vehicle
      final vehicleJson = {
        'licensePlate': licensePlate,
        'vehicleType': vehicleType,
        'owner': personJson,
      };

      // post vehicle till server
      final url = Uri.parse(vehiclesEndpoint);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vehicleJson),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        print('Server Response: ${responseBody['message']}');
        print('Added Vehicle Details: ${responseBody['vehicle']}');
        print('Total Vehicles on Server: ${responseBody['totalVehicles']}');
        break;
      } else {
        print('Failed to add vehicle: ${response.body}');
      }
    }
  }
}
