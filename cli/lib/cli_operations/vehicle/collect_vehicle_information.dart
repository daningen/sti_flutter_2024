import 'dart:io';

import 'package:cli/utils/ssn_validator.dart';

Future<Map<String, String>> collectVehicleInput() async {
  Map<String, String> vehicleInput = {};

  print("Ange regnummer:");
  vehicleInput['licensePlate'] = stdin.readLineSync()!;

  print("Ange typ av fordon:");
  vehicleInput['vehicleType'] = stdin.readLineSync()!;

  print("Ange ägare av fordon:");
  vehicleInput['name'] = stdin.readLineSync()!;

  print("Ange personnummer:");
  vehicleInput['ssn'] = stdin.readLineSync()!;

  return vehicleInput;
}
