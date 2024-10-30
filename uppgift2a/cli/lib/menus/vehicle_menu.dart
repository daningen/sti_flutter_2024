import 'dart:io';

import 'package:cli/cli_operations/vehicle_operations.dart';
import 'package:cli/utils/console.dart';

class VehicleMenu {
  static Future prompt() async {
    clearConsole();
    while (true) {
      print('Vehicles Menu');
      print('1. Create vehicle');
      print('2. List all vehicles');
      print('3. Update vehicle');
      print('4. Delete vehicle');
      print('5. Back to Main Menu');

      var input = choice();

      switch (input) {
        case 1:
          print('Creating Vehicle');
          await VehicleOperations.create();
          break;
        case 2:
          print('Listing all Vehicles');
          await VehicleOperations.list();
          break;
        case 3:
          print('Updating Vehicle');
          await VehicleOperations.update();
          break;
        case 4:
          print('Deleting Vehicle');
          await VehicleOperations.delete();
          break;
        case 5:
          return;
        default:
          print('Invalid choice');
      }
      print("\n------------------------------------\n");
    }
  }

  static int? choice() {
    // get user input for choice
    print('Enter choice: ');
    var choice = int.tryParse(stdin.readLineSync()!);
    return choice ?? 0; // Return 0 if parsing fails, to catch invalid input
  }
}
