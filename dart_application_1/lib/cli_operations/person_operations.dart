// Function to add a new person
import 'dart:io';

import 'package:dart_application_1/globals.dart';
import 'package:dart_application_1/models/person.dart';

void addPerson() {
  print("Ange namn:");
  String name = stdin.readLineSync()!;

  print("Ange personnummer (ddmmår):");
  String ssn = stdin.readLineSync()!;

  Person person = Person(name: name, ssn: ssn);
  personRepository.addPerson(person);
  print("Person tillagd!");
}

// Function to show all persons
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

// Function to update a person's information
void updatePerson() {
  print("Ange personnummer för personen du vill uppdatera:");
  String ssn = stdin.readLineSync()!;

  Person? personToUpdate = personRepository.getPersonBySecurityNumber(ssn);

  if (personToUpdate != null) {
    print("Ange nytt namn:");
    String newName = stdin.readLineSync()!;

    Person newPerson = Person(name: newName, ssn: personToUpdate.ssn);
    personRepository.update(personToUpdate,newPerson);
    print("Personen uppdaterad!");
  }
}

// Function to delete a person
void deletePerson() {
  print("Ange personnummer för personen du vill ta bort:");
  String ssn = stdin.readLineSync()!;

  Person? personToDelete = personRepository.getPersonBySecurityNumber(ssn);

  //personRepository.deletePerson(personToDelete);
  print("Personen togs inte bort för metoden är inte implamenterad.");
}
