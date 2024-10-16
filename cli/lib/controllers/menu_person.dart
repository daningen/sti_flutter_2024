import 'dart:io';

import 'package:cli/cli_operations/person_operations.dart';

void menuPerson() {
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
        addPerson();
        print("skapar person");
      // showMainMenu();

      // return;
      case 2:
        showPersons();
        print("visar alla personer");

      // return;
      case 3:
        updatePerson();
        print("uppdatera person");
      // return;
      case 4:
        deletePerson();
        print("ta bort person");
      // return;
      case 5:
        print("Tillbaka till huvudmenyn...");
        return;
      // break;
      default:
        print("Felaktigt val välj 1, 2, 3, 4 eller 5.");
    }
  }
}
