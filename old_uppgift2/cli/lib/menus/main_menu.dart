import 'dart:io';
import 'package:cli/menus/person_menu.dart';
import 'package:cli/menus/vehicle_menu.dart';
import 'package:cli/menus/parking_space_menu.dart';
import 'package:cli/menus/parking_menu.dart';
import 'package:cli/menus/bags_menu.dart';
import 'package:cli/menus/items_menu.dart';

class MainMenu {
  static Future prompt() async {
    while (true) {
      print('Main Menu');
      print('1. Manage Items');
      print('2. Manage Bags');
      print('3. Manage Persons');
      print('4. Manage Vehicles');
      print('5. Manage Parking Spaces');
      print('6. Manage Parking');
      print('7. Exit');

      var input = stdin.readLineSync();
      switch (input) {
        case '1':
          await ItemsMenu.prompt();
          break;
        case '2':
          await BagsMenu.prompt();
          break;
        case '3':
          await PersonMenu.prompt();
          break;
        case '4':
          await VehicleMenu.prompt();
          break;
        case '5':
          await ParkingSpaceMenu.prompt();
          break;
        case '6':
          await ParkingMenu.prompt();
          break;
        case '7':
          return;
        default:
          print('Invalid choice');
      }
    }
  }
}
