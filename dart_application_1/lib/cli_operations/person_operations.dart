import 'dart:io';

import 'package:dart_application_1/globals.dart';
import 'package:dart_application_1/models/person.dart';
import 'package:dart_application_1/utils/ssn_validator.dart';

void addPerson() {
  while (true) {
    // Finns licensePlate i repo?
    Person? existingPerson;
    print("Ange personnummer (ååmmdd):");
    String ssn = stdin.readLineSync()!;

    // Validera format
    if (!ssnFormat.hasMatch(ssn)) {
      print("Ogiltigt personnummer (YYMMDD). Försök igen.");
      continue;
    }

    try {
      existingPerson = personRepository.getPersonBySecurityNumber(ssn);
    } catch (e) {
      existingPerson = null;
    }

    if (existingPerson != null) {
      // Om ssn redan finns, testa ett nytt
      print(
          "Personnummer är redan upplagt. Försök igen med ett nytt personnummer.");
    } else {
      print("Ange namn:");
      String name = stdin.readLineSync()!;

      Person person = Person(name: name, ssn: ssn);
      personRepository.addPerson(person);
      print("Person tillagd!");
      break;
    }
  }
}

void showPersons() {
  List<Person> allPersons = personRepository.getAllPeople();

  if (allPersons.isEmpty) {
    print("Inga personer registrerade.");
  } else {
    print("Lista över alla personer:");
    for (Person person in allPersons) {
      print("Namn: ${person.name}, Personnummer: ${person.ssn}");
    }
  }
}

void updatePerson() {
  print("Ange personnummer för personen du vill uppdatera:");
  String ssn = stdin.readLineSync()!;

  Person? personToUpdate = personRepository.getPersonBySecurityNumber(ssn);

  if (personToUpdate != null) {
    print("Ange nytt namn:");
    String newName = stdin.readLineSync()!;
    try {
      int index = personRepository.items.indexOf(personToUpdate);
      personRepository.updatePerson(
          index, Person(name: newName, ssn: personToUpdate.ssn));
      print("Personen uppdaterad!");
    } catch (e) {
      print("Ett fel uppstod vid uppdateringen: $e");
    }
  } else {
    print("Personen med personnummer '$ssn' hittades inte.");
  }
}

void deletePerson() {
  print("Ange personnummer för personen du vill ta bort:");
  String ssn = stdin.readLineSync()!;

  Person? personToDelete = personRepository.getPersonBySecurityNumber(ssn);

  if (personToDelete != null) {
    personRepository.deletePerson(personToDelete);
    print("Personen med personnummer '$ssn' borttaget");
  } else {
    print("Personen med personnummer '$ssn' hittades inte.");
  }
}
