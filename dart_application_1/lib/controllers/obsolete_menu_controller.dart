// import 'dart:io';
// import 'package:dart_application_1/cli_operations/vehicle_operations.dart';

// void showMainMenu() {
//   print("Välkommen till Parkeringsappen!");
//   print("Vad vill du hantera?");
//   print("1. Personer");
//   print("2. Fordon");
//   print("3. Parkeringsplatser");
//   print("4. Parkeringar");
//   print("5. Avsluta");

//   print("Välj ett alternativ (1-5): ");
//   int choice = int.parse(stdin.readLineSync()!);

//   switch (choice) {
//     case 1:
//       // handlePersons();

//       break;
//     case 2:
//       handleVehicles();

//       break;
//     case 3:
//       // handleParkingSpaces();
//       break;
//     case 4:
//       // handleParkingEvents();
//       break;
//     case 5:
//       print("Avslutar programmet...");
//       break;
//     default:
//       print("Ogiltigt val. Välj ett alternativ mellan 1 och 5.");
//   }
// }

// // void handlePersons() {
// //   PersonController personController = PersonController();
// //   personController.showPersonMenu();
// // }

// void handleVehicles() {
//   print("Välkommen till parkeringen!");
//   print("1. Lägg till fordon");
//   print("2. Sök fordon");
//   print("3. parkera");
//   print("4. Lämna app");

//   int choice = int.parse(stdin.readLineSync()!);

//   switch (choice) {
//     case 1:
//       addVehicle();
//       print("hello hello i submeny, åter till huvudmeny");

//       return;
//     case 2:
//       searchVehicle();
//       print("hello i submeny, åter till huvudmeny");

//       return;
//     case 3:
//       // parkingVehicle();
//       return;
//     case 4:
//       print("Avslutar...");
//       break;
//     default:
//       print("Felaktigt val välj 1, 2, 3 eller 4.");
//   }
// }
