import 'dart:io';
import 'dart:math';
import 'package:cli/utils/generate_random_licenseplate.dart';
import 'package:cli/utils/generate_random_ssn.dart';

Future<Map<String, String>> collectPersonInput() async {
  Map<String, String> personInput = {};

  // print("Ange regnummer:");
  // vehicleInput['licensePlate'] = stdin.readLineSync()!;
  personInput['licensePlate'] = generateRandomLicensePlate();
  print("Generated License Plate: ${personInput['licensePlate']}");

  //slumpa fram ett fordon
  List<String> vehicleTypes = ['bil', 'moped', 'traktor', 'okänt'];
  String randomVehicleType =
      vehicleTypes[Random().nextInt(vehicleTypes.length)];
  personInput['vehicleType'] =
      randomVehicleType; // Set the vehicle type to a random one

  print("Ange ägare av fordon:");
  personInput['name'] = stdin.readLineSync()!;

  // Generate a random valid SSN using the separate function
  String randomSSN =
      generateRandomSSN(); // Assuming this function is in ssn_generator.dart
  personInput['ssn'] = randomSSN;

  print("Generated SSN: $randomSSN");

  return personInput;
}
