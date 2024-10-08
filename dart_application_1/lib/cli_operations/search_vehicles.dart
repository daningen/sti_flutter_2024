import 'dart:io';

import 'package:dart_application_1/models/vehicle.dart';

void searchVehicle() {
  while (true) {
    print("Ange registreringsnummer (eller 'exit' för att avsluta):");
    String licensePlate = stdin.readLineSync()!;

    if (licensePlate.toLowerCase() == "exit") {
      break;
    }
    try {
      var vehicleRepository;
      Vehicle? foundVehicle =
          vehicleRepository.getVehicleByLicensePlate(licensePlate);

      if (foundVehicle != null) {
        print("Fordon hittat:");
        print("Registreringsnummer: ${foundVehicle.licensePlate}");
        // print("Ägare: ${foundVehicle.owner}");
        print("Ägare: ${foundVehicle.owner.name}");
        print("Ägarens personnummer: ${foundVehicle.owner.securityNumber}");

        break;
      } else {
        print("Fordon med registreringsnummer '$licensePlate' not found \n");
      }
    } catch (e) {
//       print("Fordon finns ej.");
//     }
    }
  }
}
