import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:cli/config/config.dart';
import 'package:cli/models/person.dart';
import 'package:cli/models/vehicle.dart';

/// Function to update a vehicle's owner on the server
Future<void> updateVehicle() async {
  print("Ange registreringsnummer för fordonet du vill uppdatera:");
  String licensePlate = stdin.readLineSync()!;

  // Fetch the vehicle by license plate from the server
  final url = Uri.parse('$vehiclesEndpoint/$licensePlate');
  final getResponse = await http.get(url);

  // Handle the case where the vehicle doesn't exist
  if (getResponse.statusCode != 200) {
    print("Fordon ej hittat för registreringsnummer: $licensePlate");
    return;
  }

  // Parse the vehicle data from the server response
  Vehicle vehicleToUpdate = Vehicle.fromJson(jsonDecode(getResponse.body));

  // Prompt for new owner details
  print("Ange ny ägare av fordonet:");
  String newName = stdin.readLineSync()!;

  print("Ange personnummer för ny ägare (ddmmår):");
  String newSSN = stdin.readLineSync()!;

  // Create new person object with a unique ID
  var nextPersonId = vehicleToUpdate.owner.id + 1; // Increment the person ID
  Person newOwner = Person(id: nextPersonId, name: newName, ssn: newSSN);

  // Create an updated vehicle object with the new owner
  Vehicle updatedVehicle = Vehicle(
    id: vehicleToUpdate.id, // Ensure the ID remains the same
    licensePlate: vehicleToUpdate.licensePlate,
    vehicleType: vehicleToUpdate.vehicleType,
    owner: newOwner,
  );

  // Send PUT request to the server to update the vehicle
  final putResponse = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(updatedVehicle.toJson()),
  );

  if (putResponse.statusCode == 200) {
    print("Fordonets ägare uppdaterad.");
    final responseBody = jsonDecode(putResponse.body);
    print('Updated Vehicle: ${responseBody['vehicle']}');
  } else {
    print("Misslyckades att uppdatera fordonet: ${putResponse.body}");
  }
}
