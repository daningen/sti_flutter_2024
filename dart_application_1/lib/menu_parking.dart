import 'dart:io';

import 'package:dart_application_1/cli_operations/parking.dart';

void menuParking() {
  while (true) {
    print("Parkering");
    print("1. Starta parkering");
    print("2. Visa din parkering");
    print("3. Uppdatera parkering");
    print("4. Stoppa parkering");
    print("5. Gå tillbaka till huvudmenyn");

    int choice = int.parse(stdin.readLineSync()!);

    switch (choice) {
      case 1:
        print("I menu_person.dart");
        startParking();
        print("starta parkering");
      // showMainMenu();

      // return;
      case 2:
        showParking();
        print("visa parkering");

      // return;
      case 3:
        updateParking();
        print("uppdatera parkering");
      // return;
      case 4:
        stopParkingSpace();
        print("avsluta parkering");
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
