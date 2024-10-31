import 'dart:io';

import 'package:cli/forms/update_person_forms.dart';
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
      Person person = await repository.getById(allPersons[index].id);

      // Use UpdatePersonForm to handle the update interaction
      await UpdatePersonForm.showUpdateOptions(person);

      // Save the updated person
      await repository.update(person.id, person);
      print('Person updated');
    } else {
      print('Invalid input');
    }
  }

  // static Future _updateSSN(Person person) async {
  //   print('Enter new SSN: ');
  //   var ssn = stdin.readLineSync();

  //   if (Validator.isString(ssn)) {
  //     person.ssn = ssn!;
  //     await repository.update(person.id, person);
  //     print('SSN updated');
  //   } else {
  //     print('Invalid input');
  //   }
  // }

  // static Future _removeItemsFromPerson(Person person) async {
  //   print('Pick an item to remove: ');
  //   for (int i = 0; i < person.items.length; i++) {
  //     print('${i + 1}. ${person.items[i].description}');
  //   }

  //   String? input = stdin.readLineSync();

  //   if (Validator.isIndex(input, person.items)) {
  //     int index = int.parse(input!) - 1;
  //     person.items.removeAt(index);
  //     await repository.update(person.id, person);
  //     print('Item removed from person');
  //   } else {
  //     print('Invalid input');
  //   }
  // }

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
