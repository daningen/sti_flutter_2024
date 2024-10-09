import 'dart:io';

import 'package:dart_application_1/menu_person.dart';
import 'package:dart_application_1/menu_vehicle.dart';

void menu() {
  while (true) {
    print("Välkommen till huvudmenyn");
    print("Vad vill du hantera?");
    print("1. Personer");
    print("2. Fordon");
    print("3. Parkeringsplatser");
    print("4. Parkeringar");
    print("5. Avsluta");

    print("Välj ett alternativ (1-5): ");
    int choice = int.parse(stdin.readLineSync()!);

    switch (choice) {
      case 1:
        // handlePersons();
        print("hantera personer ");
        menuPerson();
      // break;
      case 2:
        // handleVehicles();
        print("hantera fordon ");
        menuVehicle();

        print("du valde 2 ");
        break;
      case 3:
        // handleParkingSpaces();
        break;
      case 4:
        // handleParkingEvents();
        break;
      case 5:
        print("Avslutar programmet...");
        return; // Avsluta loopen
      default:
        print("Ogiltigt val. Välj ett alternativ mellan 1 och 5.");
    }
  }
}
