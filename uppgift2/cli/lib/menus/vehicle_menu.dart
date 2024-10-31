import 'dart:io';
import 'package:cli/cli_operations/vehicle_operations.dart';

class VehicleMenu {
  static Future prompt() async {
    while (true) {
      print('Vehicles Menu');
      print('1. Create vehicle');
      print('2. List all vehicles');
      print('3. Update vehicle');
      print('4. Delete vehicle');
      print('5. Back to Main Menu');

      var input = stdin.readLineSync();
      switch (input) {
        case '1':
          await VehicleOperations.create();
          break;
        case '2':
          await VehicleOperations.list();
          break;
        case '3':
          await VehicleOperations.update();
          break;
        case '4':
          await VehicleOperations.delete();
          break;
        case '5':
          return;
        default:
          print('Invalid choice');
      }
    }
  }
}
