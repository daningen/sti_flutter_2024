// lib/forms/update_person_form.dart

import 'dart:io';
import 'package:cli/utils/validator.dart';
import 'package:shared/shared.dart';

class UpdatePersonForm {
  static Future<void> showUpdateOptions(Person person) async {
    print("in update_person_forms now");
    while (true) {
      print("\n------------------------------------\n");

      print(
          "What would you like to update in person: ${person.name} - [SSN: ${person.ssn}]?");
      print('1. Update name');
      print('2. Update SSN');
      // print('3. Add items to person');
      // print("in updatefooorrrrmmmm");
      // print('4. Remove items from person');
      print('5. Exit update');

      var input = stdin.readLineSync();

      if (Validator.isNumber(input)) {
        int choice = int.parse(input!);
        switch (choice) {
          case 1:
            await _updateName(person);
            break;
          case 2:
            await _updateSSN(person);
            break;
          case 4:
            await _removeItemsFromPerson(person);
            break;
          case 5:
            return; // Exit update
          default:
            print('Invalid choice');
        }
      } else {
        print('Invalid input');
      }
    }
  }

  static Future _updateName(Person person) async {
    print('Enter new name: ');
    var name = stdin.readLineSync();
    if (Validator.isString(name)) {
      person.name = name!;
      print('Name updated');
    } else {
      print('Invalid input');
    }
  }

  static Future _updateSSN(Person person) async {
    print('Enter new SSN: ');
    var ssn = stdin.readLineSync();
    if (Validator.isString(ssn)) {
      person.ssn = ssn!;
      print('SSN updated');
    } else {
      print('Invalid input');
    }
  }

  static Future _removeItemsFromPerson(Person person) async {
    print('Pick an item to remove: ');
    for (int i = 0; i < person.items.length; i++) {
      print('${i + 1}. ${person.items[i].description}');
    }
    String? input = stdin.readLineSync();
    if (Validator.isIndex(input, person.items)) {
      int index = int.parse(input!) - 1;
      person.items.removeAt(index);
      print('Item removed');
    } else {
      print('Invalid input');
    }
  }
}
