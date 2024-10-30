import 'dart:io';
import 'package:cli/cli_operations/parking_space_operations.dart';

class ParkingSpaceMenu {
  static Future prompt() async {
    while (true) {
      print('Parking Space Menu');
      print('1. Create parking space');
      print('2. List all parking spaces');
      print('3. Update parking space');
      print('4. Delete parking space');
      print('5. Back to Main Menu');

      var input = stdin.readLineSync();
      switch (input) {
        case '1':
          await ParkingSpaceOperations.create();
          break;
        case '2':
          await ParkingSpaceOperations.list();
          break;
        case '3':
          await ParkingSpaceOperations.update();
          break;
        case '4':
          await ParkingSpaceOperations.delete();
          break;
        case '5':
          return;
        default:
          print('Invalid choice');
      }
    }
  }
}
