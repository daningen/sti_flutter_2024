import 'dart:io';
import 'package:cli/repositories/person_repository.dart';
import 'package:cli/repositories/vehicle_repository.dart';
import 'package:cli/utils/validator.dart';
import 'package:cli_shared/cli_shared.dart';

VehicleRepository vehicleRepo = VehicleRepository();
PersonRepository personRepo = PersonRepository();

class VehicleOperations {
  static Future create() async {
    print('Enter license plate: ');
    var licensePlate = stdin.readLineSync();

    print('Enter vehicle type (e.g., car, motorcycle): ');
    var vehicleType = stdin.readLineSync();

    print('Select an owner from the list:');
    List<Person> allPersons = await personRepo.getAll();
    if (allPersons.isEmpty) {
      print('No owners found. Please create a person first.');
      return;
    }

    for (int i = 0; i < allPersons.length; i++) {
      print('${i + 1}. ${allPersons[i].name} (SSN: ${allPersons[i].ssn})');
    }

    String? input = stdin.readLineSync();
    if (!Validator.isIndex(input, allPersons)) {
      print('Invalid choice');
      return;
    }

    int selectedIndex = int.parse(input!) - 1;
    Person selectedOwner = allPersons[selectedIndex];

    if (Validator.isString(licensePlate) && Validator.isString(vehicleType)) {
      Vehicle vehicle = Vehicle(
        licensePlate: licensePlate!,
        vehicleType: vehicleType!,
      );
      vehicle.owner.target = selectedOwner;

      await vehicleRepo.create(vehicle);
      print('Vehicle created successfully.');
    } else {
      print('Invalid input');
    }
  }

  static Future list() async {
    // Code for listing all vehicles
  }

  static Future update() async {
    // Code for updating a vehicle
  }

  static Future delete() async {
    // Code for deleting a vehicle
  }
}
