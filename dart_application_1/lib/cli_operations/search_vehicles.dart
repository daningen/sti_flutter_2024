import 'dart:io';

import 'package:dart_application_1/globals.dart';
import 'package:dart_application_1/models/vehicle.dart';

// void searchVehicle() {
//   while (true) {
//     print("Ange registreringsnummer (eller 'exit' för att avsluta):");
//     String licensePlate = stdin.readLineSync()!;

//     if (licensePlate.toLowerCase() == "exit") {
//       break;
//     }
//     try {
//       // Use the provided vehicleRepository to search for the vehicle
//       // ignore: prefer_typing_uninitialized_variables
//       var vehicleRepository;
//       Vehicle? foundVehicle =
//           vehicleRepository.getVehicleByLicensePlate(licensePlate);

//       print("Fordon hittat:");
//       print("Registreringsnummer: ${foundVehicle?.licensePlate}");
//       print("Ägare: ${foundVehicle?.owner.name}");
//       print("Ägarens personnummer: ${foundVehicle?.owner.ssn}");
//       break;
//     } catch (e) {
//       print("Ett fel uppstod: $e");
//     }
//   }
// }
void searchVehicle() {
  while (true) {
    print("Ange registreringsnummer (eller 'exit' för att avsluta):");
    String licensePlate = stdin.readLineSync()!;

    if (licensePlate.toLowerCase() == "exit") {
      break;
    }

    try {
      // Directly use the global vehicleRepository
      Vehicle? foundVehicle =
          vehicleRepository.getVehicleByLicensePlate(licensePlate);

      if (foundVehicle != null) {
        print("Fordon hittat:");
        print("Registreringsnummer: ${foundVehicle.licensePlate}");
        print("Ägare: ${foundVehicle.owner.name}");
        print("Ägarens personnummer: ${foundVehicle.owner.ssn}");
        break;
      } else {
        print("Fordon med registreringsnummer '$licensePlate' hittades inte.");
      }
    } catch (e) {
      print("Ett fel uppstod: $e");
    }
  }
}
