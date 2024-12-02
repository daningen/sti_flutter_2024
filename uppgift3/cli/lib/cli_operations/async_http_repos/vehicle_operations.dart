import 'dart:io';
// import 'dart:convert';

import 'package:cli/utils/validator.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';

VehicleRepository vehicleRepo = VehicleRepository();
PersonRepository personRepo = PersonRepository();

class VehicleOperations {
  static Future create() async {
    print('Enter license plate: ');
    var licensePlate = stdin.readLineSync();

    // Check if the license plate already exists
    List<Vehicle> allVehicles = await vehicleRepo.getAll();
    bool licensePlateExists =
        allVehicles.any((v) => v.licensePlate == licensePlate);
    if (licensePlateExists) {
      print(
          'A vehicle with this license plate already exists. Please enter a unique license plate.');
      return; // Exit the method early if a duplicate is found
    }

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

      print('Data to be sent to server (Create): ${vehicle.toJson()}');

      try {
        await vehicleRepo.create(vehicle);
        print('Vehicle created successfully.');
      } catch (e) {
        print('Error while creating vehicle: $e');
      }
    } else {
      print('Invalid input');
    }
  }

  static Future list() async {
    List<Vehicle> allVehicles = await vehicleRepo.getAll();
    for (int i = 0; i < allVehicles.length; i++) {
      final owner = allVehicles[i].owner.target;
      final ownerName = owner?.name ?? 'Unknown';
      final ownerSSN = owner?.ssn ?? 'Unknown';

      print(
        '${i + 1}. License Plate: ${allVehicles[i].licensePlate}, '
        'Type: ${allVehicles[i].vehicleType}, '
        'Owner: $ownerName (SSN: $ownerSSN)',
      );
    }
  }

  static Future update() async {
    print('Pick an index to update: ');
    List<Vehicle> allVehicles = await vehicleRepo.getAll();
    for (int i = 0; i < allVehicles.length; i++) {
      print('${i + 1}. License Plate: ${allVehicles[i].licensePlate}');
    }

    String? input = stdin.readLineSync();

    if (Validator.isIndex(input, allVehicles)) {
      int index = int.parse(input!) - 1;

      print('Enter new license plate: ');
      var licensePlate = stdin.readLineSync();

      print('Enter new vehicle type: ');
      var vehicleType = stdin.readLineSync();

      print('Select a new owner from the list:');
      List<Person> allPersons = await personRepo.getAll();
      if (allPersons.isEmpty) {
        print('No owners found. Please create a person first.');
        return;
      }

      for (int i = 0; i < allPersons.length; i++) {
        print('${i + 1}. ${allPersons[i].name} (SSN: ${allPersons[i].ssn})');
      }

      input = stdin.readLineSync();
      if (!Validator.isIndex(input, allPersons)) {
        print('Invalid choice');
        return;
      }

      int selectedIndex = int.parse(input!) - 1;
      Person selectedOwner = allPersons[selectedIndex];

      if (Validator.isString(licensePlate) && Validator.isString(vehicleType)) {
        Vehicle vehicle = allVehicles[index];
        vehicle.licensePlate = licensePlate!;
        vehicle.vehicleType = vehicleType!;
        vehicle.owner.target = selectedOwner;

        try {
          await vehicleRepo.update(vehicle.id, vehicle);
          print('Vehicle updated successfully.');
        } catch (e) {
          print('Failed to update vehicle: $e');
        }
      } else {
        print('Invalid input');
      }
    } else {
      print('Invalid input');
    }
  }

  static Future delete() async {
    print('Pick an index to delete: ');
    List<Vehicle> allVehicles = await vehicleRepo.getAll();
    for (int i = 0; i < allVehicles.length; i++) {
      print('${i + 1}. License Plate: ${allVehicles[i].licensePlate}');
    }

    String? input = stdin.readLineSync();

    if (Validator.isIndex(input, allVehicles)) {
      int index = int.parse(input!) - 1;
      try {
        await vehicleRepo.delete(allVehicles[index].id);
        print('Vehicle deleted successfully.');
      } catch (e) {
        print('Failed to delete vehicle: $e');
      }
    } else {
      print('Invalid input');
    }
  }
}
