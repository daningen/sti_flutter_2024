import 'dart:io';

import 'package:cli/controllers/menu_parking.dart';
import 'package:cli/controllers/menu_parking_space.dart';
import 'package:cli/controllers/menu_person.dart';
import 'package:cli/controllers/menu_vehicle.dart';

Future<void> menu() async {
  while (true) {
    print("Välkommen till huvudmenyn YYY");
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
        print("hantera personer ");
        await menuPerson();
        break;

      case 2:
        print("hantera fordon ");
        await menuVehicle();
        break;

      case 3:
        print("hantera parkeringsplatser ");
        await menuParkingSpace();
        break;
      case 4:
        print("parkera fordon ");
        await menuParking();
        break;

      case 5:
        print("Avslutar programmet...");
        return;

      default:
        print("Ogiltigt val. Välj ett alternativ mellan 1 och 5.");
    }
  }
}
