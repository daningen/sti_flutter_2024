import 'dart:io';

import 'package:cli/menus/parking_menu.dart';
import 'package:cli/menus/parking_space_menu.dart';
import 'package:cli/menus/person_menu.dart';
import 'package:cli/menus/vehicle_menu.dart';

import 'package:cli/utils/console.dart';
// import 'package:cli/menus/bags_menu.dart';
// import 'package:cli/menus/items_menu.dart';

class MainMenu {
  static Future prompt() async {
    clearConsole();

    while (true) {
      // clear the console

      // prompt options to edit items, bags, or exit
      print('Main Menu');

      print('1. Manage Persons');
      print('2. Manage Vehicles');
      print('3. Manage Parking spaces');
      print('4. Manage Parking');
      print('5. Exit');
      var input = choice();
      switch (input) {
        case 1:
          await PersonMenu.prompt();
        case 2:
          await VehicleMenu.prompt();
        case 3:
          await ParkingSpaceMenu.prompt();
        case 4:
          await ParkingMenu.prompt();
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
    var choice = int.parse(stdin.readLineSync()!);
    return choice;
  }
}
