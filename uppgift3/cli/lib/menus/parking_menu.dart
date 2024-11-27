import 'dart:io';

import 'package:cli/cli_operations/parking_operations.dart';
import 'package:cli/utils/console.dart';

class ParkingMenu {
  static Future prompt() async {
    clearConsole();
    while (true) {
      print('Parking Menu');
      print('1. Create parking');
      print('2. List all parking sessions');
      print('3. Update parking');
      print('4. Stop parking');
      print('5. Delete parking');
      print('6. Back to Main Menu');

      var input = choice();

      switch (input) {
        case 1:
          print('Creating Parking Session');
          await ParkingOperations.create();
          break;
        case 2:
          print('Listing all Parking Sessions');
          await ParkingOperations.list();
          break;
        case 3:
          print('Updating Parking Session');
          await ParkingOperations.update();
          break;
        case 4:
          print('Deleting Parking Session');
          await ParkingOperations.stop();
          break;
        case 5:
          print('Deleting Parking Session');
          await ParkingOperations.delete();
          break;
        case 6:
          return; // Exit the menu and return to the main menu
        default:
          print('Invalid choice');
      }
      print("\n------------------------------------\n");
    }
  }

  static int? choice() {
    // Get user input for choice
    print('Enter choice: ');
    var choice = int.tryParse(stdin.readLineSync()!);
    return choice ?? 0; // Return 0 if parsing fails, to catch invalid input
  }
}
