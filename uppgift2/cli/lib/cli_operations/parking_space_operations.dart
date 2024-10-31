import 'dart:io';
import 'package:cli/repositories/parking_space_repository.dart';
import 'package:cli/utils/validator.dart';
import 'package:cli_shared/cli_shared.dart';

ParkingSpaceRepository repository = ParkingSpaceRepository();

class ParkingSpaceOperations {
  static Future create() async {
    print('Enter parking space address: ');
    var address = stdin.readLineSync();

    print('Enter price per hour: ');
    var priceInput = stdin.readLineSync();

    if (Validator.isString(address) && Validator.isNumber(priceInput)) {
      int pricePerHour = int.parse(priceInput!);
      ParkingSpace parkingSpace = ParkingSpace(
        address: address!,
        pricePerHour: pricePerHour,
      );

      await repository.create(parkingSpace);
      print('Parking space created successfully.');
    } else {
      print('Invalid input');
    }
  }

  static Future list() async {
    // Code for listing all parking spaces
  }

  static Future update() async {
    // Code for updating a parking space
  }

  static Future delete() async {
    // Code for deleting a parking space
  }
}
