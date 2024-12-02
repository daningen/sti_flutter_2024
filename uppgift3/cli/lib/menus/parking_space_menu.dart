import 'dart:io';

import 'package:cli/cli_operations/async_http_repos/parking_space_operations.dart';
import 'package:cli/utils/console.dart';

class ParkingSpaceMenu {
  static Future prompt() async {
    clearConsole();
    while (true) {
      print('Parking space Menu');
      print('1. Create parking space');
      print('2. List all parking spaces');
      print('3. Update parking space');
      print('4. Delete parking space');
      print('5. Back to Main Menu');

      var input = choice();

      switch (input) {
        case 1:
          print('Creating Parking Space');
          await ParkingSpaceOperations.create();
          break;
        case 2:
          print('Listing all Parking Spaces');
          await ParkingSpaceOperations.list();
          break;
        case 3:
          print('Updating Parking Space');
          await ParkingSpaceOperations.update();
          break;
        case 4:
          print('Deleting Parking Space');
          await ParkingSpaceOperations.delete();
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
