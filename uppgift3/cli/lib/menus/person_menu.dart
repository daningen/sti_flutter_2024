import 'dart:io';

import 'package:cli/cli_operations/async_http_repos/person_operations.dart';
import 'package:cli/utils/console.dart';

class PersonMenu {
  static Future prompt() async {
    clearConsole();
    while (true) {
      print('Persons Menu');
      print('1. Create person');
      print('2. List all Persons');
      print('3. Update Person');
      print('4. Delete Person');
      print('5. Back to Main Menu');

      var input = choice();

      switch (input) {
        case 1:
          print('Creating Person');
          await PersonOperations.create();
        case 2:
          print('Listing all Persons');
          await PersonOperations.list();
        case 3:
          print('Updating Person');
          await PersonOperations.update();
        case 4:
          print('Deleting Person');
          await PersonOperations.delete();
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
