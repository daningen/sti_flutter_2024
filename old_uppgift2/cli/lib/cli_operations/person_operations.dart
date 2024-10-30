import 'dart:io';
import 'package:cli/repositories/person_repository.dart';
import 'package:cli/utils/validator.dart';
import 'package:cli_shared/cli_shared.dart';

PersonRepository repository = PersonRepository();

class PersonOperations {
  static Future create() async {
    print('Enter name: ');
    var nameInput = stdin.readLineSync();

    print('Enter SSN (YYMMDD): ');
    var ssnInput = stdin.readLineSync();

    if (Validator.isString(nameInput) && Validator.isSSN(ssnInput)) {
      Person person = Person(name: nameInput!, ssn: ssnInput!);
      await repository.create(person);
      print('Person created successfully.');
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
    // Code for updating a person (similar structure to create)
  }

  static Future delete() async {
    // Code for deleting a person
  }
}
