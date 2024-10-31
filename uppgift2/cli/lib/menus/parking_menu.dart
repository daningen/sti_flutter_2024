import 'dart:io';
import 'package:cli/cli_operations/parking_operations.dart';

class ParkingMenu {
  static Future prompt() async {
    while (true) {
      print('Parking Menu');
      print('1. Create parking session');
      print('2. List all parking sessions');
      print('3. Update parking session');
      print('4. Stop parking session');
      print('5. Back to Main Menu');

      var input = stdin.readLineSync();
      switch (input) {
        case '1':
          await ParkingOperations.create();
          break;
        case '2':
          await ParkingOperations.list();
          break;
        case '3':
          await ParkingOperations.update();
          break;
        case '4':
          await ParkingOperations.stop();
          break;
        case '5':
          return;
        default:
          print('Invalid choice');
      }
    }
  }
}
