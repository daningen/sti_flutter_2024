import 'dart:io';

import 'package:dart_application_1/cli_operations/vehicle_operations.dart';

void menuVehicles() {
  print("hellooooo");
}

void menuVehicle() {
  while (true) {
    print("Välkommen till fordonsappen");
    print("1. Lägg till fordon");
    print("2. Sök alla fordon");
    // print("2. Sök ett fordon");
    print("3. Uppdatera fordon");
    print("4. Ta bort fordon");
    // print("3. parkera");
    print("5. Tillbaka till huvudmenyn");

    int choice = int.parse(stdin.readLineSync()!);

    switch (choice) {
      case 1:
        print("i menu_vehicle.dart");
        addVehicle();
        print("fordon skapat");
      // break;
      // return;
      case 2:
        // searchVehicle();
        showVehicles();
        print("fordon hittat");

      // return;
      case 3:
        updateVehicle();
        // parkingVehicle();
        print("fordon parkerat");
      // return;
      case 4:
        deleteVehicle();
      // return;
      // break;
      case 5:
        print("tillbaka till huvudmenyn  ...");
        return;
      // break;
      default:
        print("Felaktigt val välj 1, 2, 3 eller 4.");
    }
  }
}
