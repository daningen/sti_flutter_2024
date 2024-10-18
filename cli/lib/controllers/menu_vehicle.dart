import 'dart:io';

import 'package:cli/cli_operations/vehicle/add_vehicle_to_server2.dart';
import 'package:cli/cli_operations/vehicle/vehicle_operations.dart';

Future<void> menuVehicle() async {
  while (true) {
    print("Välkommen till fordonsappen");
    print("1. Lägg till fordon");
    print("2. Visa alla fordon");
    print("3. Uppdatera fordon");
    print("4. Ta bort fordon");
    print("5. Tillbaka till huvudmenyn");

    int choice = int.parse(stdin.readLineSync()!);

    switch (choice) {
      case 1:
        print("anropar addVehicleToServer...");

        await addVehicleToServer2();
        // Ensure the user is notified only after the vehicle is created
        print("Fordon skapat, stämmer detta");

        break;
      case 2:
        print("Visar alla fordon...");
        // await showVehicles();
        print("Fordon hittat");
        break;
      case 3:
        print("Updating vehicle...");
        break;
      case 4:
        print("Deleting vehicle...");
        await deleteVehicle(); // Ensure delete operation is awaited
        print("Fordon borttaget");
        break;
      case 5:
        print("Tillbaka till huvudmenyn...");
        return;
      // return; // Exit vehiclemeny och åter huvudmeny
      default:
        print("Felaktigt val välj 1, 2, 3 eller 4.");
    }
  }
}
