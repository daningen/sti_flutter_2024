import 'dart:io';

import 'package:cli/cli_operations/parkingspace/add_parking_space.dart';
import 'package:cli/cli_operations/parkingspace/delete_parking_space.dart';
import 'package:cli/cli_operations/parkingspace/show_parking_spaces.dart';
import 'package:cli/cli_operations/parkingspace/update_parking_space.dart';

Future<void> menuParkingSpace() async {
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
        await addParkingSpace();
        print("skapar parkeringsplats");
        break;
      // return;
      case 2:
        await showParkingSpaces();
        print("visar alla parkeringsplatser");
        break;
      // return;
      case 3:
        await updateParkingSpace();
        print("uppdatera parkeringsplats");
        break;
      case 4:
        await deleteParkingSpace();
        print("ta bort parkeringsplats");
        break;
      case 5:
        print("Tillbaka till huvudmenyn...");
        return;
      // break;
      default:
        print("Felaktigt val välj 1, 2, 3, 4 eller 5.");
    }
  }
}
