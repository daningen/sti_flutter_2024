import 'dart:io';

import 'package:cli/cli_operations/parking/add_parking.dart';
import 'package:cli/cli_operations/parking/show_parking.dart';
import 'package:cli/cli_operations/parking/stop_parking.dart';
import 'package:cli/cli_operations/parking/update_parking.dart';

Future<void> menuParking() async {
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
        await addParking();
        print("starta parkering");

      // return;
      case 2:
        await showParking();
        print("visa parkering");

      // return;
      case 3:
        await updateParking();
        print("uppdatera parkering");
      // return;
      case 4:
        await stopParking();
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
