import 'dart:io';

import 'package:cli/repositories/person_repository.dart';
import 'package:cli/utils/validator.dart';
import 'package:cli_shared/cli_shared.dart';

PersonRepository repository = PersonRepository();

class PersonOperations {
  static Future create() async {
    print('Enter name: ');
    var nameInput = stdin.readLineSync();

    print('Enter SSN: ');
    var ssnInput = stdin.readLineSync();
    if (Validator.isString(nameInput) && Validator.isValidSSN(ssnInput)) {
      Person person = Person(name: nameInput!, ssn: ssnInput!);
      print("call repo for create on cli/repositories/person_repository");
      await repository.create(person);
      print('Person created');
    } else {
      print('Invalid input');
    }
  }

  static Future list() async {
    List<Person> allPersons = await repository.getAll();
    for (int i = 0; i < allPersons.length; i++) {
      print('${i + 1}. ${allPersons[i].name} - [SSN: ${allPersons[i].ssn}]');
    }
  }

  static Future update() async {
    print('Pick the number of the post to update: ');
    List<Person> allPersons = await repository.getAll();
    for (int i = 0; i < allPersons.length; i++) {
      print('${i + 1}. ${allPersons[i].name}');
    }

    String? input = stdin.readLineSync();

    if (Validator.isIndex(input, allPersons)) {
      int index = int.parse(input!) - 1;

      while (true) {
        print("\n------------------------------------\n");

        Person person = await repository.getById(allPersons[index].id);

        print(
            "What would you like to update in person: ${person.name} - [SSN: ${person.ssn}]?");

        print('1. update name');
        print('2. Update SSN');
        // print('3. Add items to person');
        // print('4. Remove items from person');

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
            // case 3:
            //   await _addItemsToPerson(person);
            //   break;
            case 4:
              await _removeItemsFromPerson(person);
              break;
            default:
              print('Invalid choice');
          }
        } else {
          print('Invalid input');
        }
        print("Would you like to update anything else? (y/n)");
        input = stdin.readLineSync();
        if (input == 'n') {
          break;
        }
      }
    } else {
      print('Invalid input');
    }
  }

  static Future _updateName(Person person) async {
    print('Enter new name: ');
    var name = stdin.readLineSync();

    if (Validator.isString(name)) {
      person.name = name!;
      await repository.update(person.id, person);
      print('Person updated');
    } else {
      print('Invalid input');
    }
  }

  static Future _updateSSN(Person person) async {
    print('Enter new SSN: ');
    var ssn = stdin.readLineSync();

    if (Validator.isString(ssn)) {
      person.ssn = ssn!;
      await repository.update(person.id, person);
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
      await repository.update(person.id, person);
      print('Item removed from person');
    } else {
      print('Invalid input');
    }
  }

  static Future delete() async {
    print('Pick an index to delete: ');
    List<Person> allPersons = await repository.getAll();
    for (int i = 0; i < allPersons.length; i++) {
      print('${i + 1}. ${allPersons[i].name}');
    }

    String? input = stdin.readLineSync();

    if (Validator.isIndex(input, allPersons)) {
      int index = int.parse(input!) - 1;
      await repository.delete(allPersons[index].id);
      print('Person deleted');
    } else {
      print('Invalid input');
    }
  }
}
