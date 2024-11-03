import 'dart:io';

import 'package:cli/forms/update_person_forms.dart';
import 'package:cli/repositories/person_repository.dart';
import 'package:cli/utils/validator.dart';
import 'package:cli_shared/cli_shared.dart';

PersonRepository repository = PersonRepository();

class PersonOperations {
  static Future create() async {
    // Prompt for name and SSN
    final name = _promptForInput('Enter name: ');
    final ssn = _promptForInput('Enter SSN: ');

    // Create a Person instance with the provided input
    final person = Person(name: name, ssn: ssn);

    // Validate input
    if (isInputValid(person.name, person.ssn)) {
      print(
          "Calling repository to create person in cli/repositories/person_repository");
      await repository.create(person);
      print('Person created');
    } else {
      print('Invalid input');
    }
  }

  // Validation method for name and SSN (made public for testing)
  static bool isInputValid(String? name, String? ssn) {
    return Validator.isString(name) && Validator.isValidSSN(ssn);
  }

  static String _promptForInput(String prompt) {
    print(prompt);
    return stdin.readLineSync() ?? '';
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
