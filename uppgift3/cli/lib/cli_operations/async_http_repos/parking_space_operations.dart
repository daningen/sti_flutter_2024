import 'dart:io';

import 'package:cli/utils/validator.dart';

import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';
// import 'package:http/http.dart' as http;

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

      try {
        // create p-space
        await repository.create(parkingSpace);
        print('Parking space created successfully.');
      } catch (e) {
        print('Error while creating parking space: $e');
      }
    } else {
      print('Invalid input');
    }
  }

  static Future list() async {
    try {
      List<ParkingSpace> allParkingSpaces = await repository.getAll();
      for (int i = 0; i < allParkingSpaces.length; i++) {
        print(
          '${i + 1}. Address: ${allParkingSpaces[i].address}, Price per Hour: ${allParkingSpaces[i].pricePerHour}',
        );
      }
    } catch (e) {
      print('Failed to retrieve parking spaces: $e');
    }
  }

  static Future update() async {
    try {
      print('Pick an index to update: ');
      List<ParkingSpace> allParkingSpaces = await repository.getAll();
      for (int i = 0; i < allParkingSpaces.length; i++) {
        print('${i + 1}. Address: ${allParkingSpaces[i].address}');
      }

      String? input = stdin.readLineSync();

      if (Validator.isIndex(input, allParkingSpaces)) {
        int index = int.parse(input!) - 1;

        print('Enter new address: ');
        var address = stdin.readLineSync();

        print('Enter new price per hour: ');
        var priceInput = stdin.readLineSync();

        if (Validator.isString(address) && Validator.isNumber(priceInput)) {
          int pricePerHour = int.parse(priceInput!);
          ParkingSpace parkingSpace = allParkingSpaces[index];
          parkingSpace.address = address!;
          parkingSpace.pricePerHour = pricePerHour;

          await repository.update(parkingSpace.id, parkingSpace);
          print('Parking space updated successfully.');
        } else {
          print('Invalid input');
        }
      } else {
        print('Invalid input');
      }
    } catch (e) {
      print('Failed to update parking space: $e');
    }
  }

  static Future delete() async {
    try {
      print('Pick an index to delete: ');
      List<ParkingSpace> allParkingSpaces = await repository.getAll();
      for (int i = 0; i < allParkingSpaces.length; i++) {
        print('${i + 1}. Address: ${allParkingSpaces[i].address}');
      }

      String? input = stdin.readLineSync();

      if (Validator.isIndex(input, allParkingSpaces)) {
        int index = int.parse(input!) - 1;
        await repository.delete(allParkingSpaces[index].id);
        print('Parking space deleted successfully.');
      } else {
        print('Invalid input');
      }
    } catch (e) {
      print('Failed to delete parking space: $e');
    }
  }
}
