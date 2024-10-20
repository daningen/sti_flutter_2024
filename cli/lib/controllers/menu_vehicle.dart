import 'dart:io';

import 'package:cli/cli_operations/vehicle/add_vehicle.dart';
import 'package:cli/cli_operations/vehicle/delete_vehicle.dart';
import 'package:cli/cli_operations/vehicle/show_vehicles.dart';
import 'package:cli/cli_operations/vehicle/update_vehicle.dart';

Future<void> menuVehicle() async {
  while (true) {
    print("Välkommen till fordonsappen");
    print("1. Lägg till fordon");
    print("2. Visa alla fordon");
    print("3. Uppdatera fordon");
    print("4. Ta bort fordon");
    print("5. Tillbaka till huvudmenyn");

    // Handle invalid input gracefully
    String? input = stdin.readLineSync();
    if (input == null || int.tryParse(input) == null) {
      print("Felaktigt val. Ange ett nummer.");
      continue;
    }
    int choice = int.parse(input);

    switch (choice) {
      case 1:
        print("Anropar addVehicleToServer...");

        await addVehicle();

        print("Fordon skapat, stämmer detta");

        break;
      case 2:
        print("Visar alla fordon...");
        await showVehicles();
        break;
      case 3:
        print("Uppdaterar fordon...");
        await updateVehicle(); // Uncomment or implement this function
        break;
      case 4:
        print("Tar bort fordon...");
        await deleteVehicle(); // Ensure delete operation is awaited
        print("Fordon borttaget");
        break;
      case 5:
        print("Tillbaka till huvudmenyn...");
        return; // Exit the vehicle menu
      default:
        print("Felaktigt val, välj 1, 2, 3 eller 4.");
    }
  }
}
