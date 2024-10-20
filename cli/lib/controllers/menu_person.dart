import 'dart:io';

import 'package:cli/cli_operations/person/add_person.dart';
import 'package:cli/cli_operations/person/delete_person.dart';
import 'package:cli/cli_operations/person/show_persons.dart';
import 'package:cli/cli_operations/person/update_person.dart';

Future<void> menuPerson() async {
  // Make this function async
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
        await addPerson(); // Await the async function
        print("skapar person");
        break;

      case 2:
        await showPersons(); // Await the async function
        print("visar alla personer");
        break;

      case 3:
        await updatePerson(); // Await the async function
        print("uppdatera person");
        break;

      case 4:
        await deletePerson(); // Await the async function
        print("ta bort person");
        break;

      case 5:
        print("Tillbaka till huvudmenyn...");
        return; // Exit the menu
      default:
        print("Felaktigt val välj 1, 2, 3, 4 eller 5.");
    }
  }
}
