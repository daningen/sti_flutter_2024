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
  personInput['vehicleType'] = randomVehicleType;

  print("Ange ägare av fordon:");
  personInput['name'] = stdin.readLineSync()!;

  // Generera random pnr(SSN)
  String randomSSN = generateRandomSSN();
  personInput['ssn'] = randomSSN;

  print("Generated SSN: $randomSSN");

  return personInput;
}
