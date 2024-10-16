import 'dart:io';

import 'package:cli/controllers/menu_parking.dart';
import 'package:cli/controllers/menu_parking_space.dart';
import 'package:cli/controllers/menu_person.dart';
import 'package:cli/controllers/menu_vehicle.dart';

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
        menuParkingSpace();
        print("hantera parkeringsplatser ");
      // break;
      case 4:
        menuParking();
        print("parkera fordon ");
        // break;
        break;
      case 5:
        print("Avslutar programmet...");
        return; // Avsluta loopen
      default:
        print("Ogiltigt val. Välj ett alternativ mellan 1 och 5.");
    }
  }
}
