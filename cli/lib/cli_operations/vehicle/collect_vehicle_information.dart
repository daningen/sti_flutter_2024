import 'dart:io';
import 'dart:math';
import 'package:cli/utils/generate_random_licenseplate.dart';
import 'package:cli/utils/generate_random_ssn.dart';

Future<Map<String, String>> collectVehicleInput() async {
  Map<String, String> vehicleInput = {};

  // print("Ange regnummer:");
  // vehicleInput['licensePlate'] = stdin.readLineSync()!;
  vehicleInput['licensePlate'] = generateRandomLicensePlate();
  print("Generated License Plate: ${vehicleInput['licensePlate']}");

  //slumpa fram ett fordon
  List<String> vehicleTypes = ['bil', 'moped', 'traktor', 'okänt'];
  String randomVehicleType =
      vehicleTypes[Random().nextInt(vehicleTypes.length)];
  vehicleInput['vehicleType'] =
      randomVehicleType; // Set the vehicle type to a random one

  print("Ange ägare av fordon:");
  vehicleInput['name'] = stdin.readLineSync()!;

  // Generate a random valid SSN using the separate function
  String randomSSN =
      generateRandomSSN(); // Assuming this function is in ssn_generator.dart
  vehicleInput['ssn'] = randomSSN;

  print("Generated SSN: $randomSSN");

  return vehicleInput;
}
