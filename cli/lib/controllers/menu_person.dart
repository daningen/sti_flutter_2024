import 'dart:io';

import 'package:cli/cli_operations/person/add_person.dart';
import 'package:cli/cli_operations/person/delete_person.dart';
import 'package:cli/cli_operations/person/show_persons.dart';
import 'package:cli/cli_operations/person/update_person.dart';

Future<void> menuPerson() async {
  while (true) {
    print("Välkommen till parkeringen!");
    print("1. Skapa person");
    print("2. Visa alla personer");
    print("3. Uppdatera person");
    print("4. Ta bort person");
    print("5. Gå tillbaka till huvudmenyn");

    int choice = int.parse(stdin.readLineSync()!);

    switch (choice) {
      case 1:
        print("I menu_person.dart");
        await addPerson();
        print("skapar person");
        break;

      case 2:
        await showPersons();
        print("visar alla personer");
        break;

      case 3:
        await updatePerson();
        print("uppdatera person");
        break;

      case 4:
        await deletePerson();
        print("ta bort person");
        break;

      case 5:
        print("Tillbaka till huvudmenyn...");
        return;
      default:
        print("Felaktigt val välj 1, 2, 3, 4 eller 5.");
    }
  }
}
