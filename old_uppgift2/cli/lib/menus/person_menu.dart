import 'dart:io';
import 'package:cli/cli_operations/person_operations.dart';

class PersonMenu {
  static Future prompt() async {
    while (true) {
      print('Persons Menu');
      print('1. Create person');
      print('2. List all persons');
      print('3. Update person');
      print('4. Delete person');
      print('5. Back to Main Menu');

      var input = stdin.readLineSync();
      switch (input) {
        case '1':
          await PersonOperations.create();
          break;
        case '2':
          await PersonOperations.list();
          break;
        case '3':
          await PersonOperations.update();
          break;
        case '4':
          await PersonOperations.delete();
          break;
        case '5':
          return;
        default:
          print('Invalid choice');
      }
    }
  }
}
