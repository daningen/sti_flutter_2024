import 'dart:io';

import 'package:dart_application_1/cli_operations/parking_space.dart';

void menuParkingSpace() {
  while (true) {
    print("Parkeringsplatser!");
    print("1. Skapa parkeringsplats");
    print("2. Visa parkeringsplatser");
    print("3. Uppdatera parkeringsplaats");
    print("4. Ta bort parkeringsplats");
    print("5. Gå tillbaka till huvudmenyn");

    int choice = int.parse(stdin.readLineSync()!);

    switch (choice) {
      case 1:
        print("I menu_person.dart");
        addParkingSpace();
        print("skapar parkeringsplats");

      // return;
      case 2:
        showParkingSpaces();
        print("visar alla parkeringsplatser");

      // return;
      case 3:
        updateParkingSpace();
        print("uppdatera parkeringsplats");
      // return;
      case 4:
        deleteParkingSpace();
        print("ta bort parkeringsplats");
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
