import 'dart:io';
import 'package:cli/globals.dart';
import 'package:cli/models/person.dart';
import 'package:cli/models/vehicle.dart';
import 'package:cli/utils/ssn_validator.dart';

void updateVehicle() {
  print("Ange registreringsnummer för fordonet du vill uppdatera:");
  String licensePlate = stdin.readLineSync()!;
  //sök fordon
  Vehicle? vehicleToUpdate =
      vehicleRepository.getVehicleByLicensePlate(licensePlate);

  int index = vehicleRepository.items.indexOf(vehicleToUpdate!);

  print("Ange ny ägare av fordonet:");
  String newName = stdin.readLineSync()!;

  print("Ange personnummer för ny ägare (ddmmår):");
  String newSSN = stdin.readLineSync()!;
  //skapa nytt personobjekt
  Person newOwner = Person(name: newName, ssn: newSSN);

  //uppdatera objektet updatedVehicle
  Vehicle updatedVehicle = Vehicle(
      vehicleToUpdate.licensePlate, vehicleToUpdate.vehicleType, newOwner);

  //Ersätt platsen i listan med de nya uppgifterna
  vehicleRepository.items[index] = updatedVehicle;
  print("Fordonets ägare uppdaterad.");
}

void addVehicle() {
  while (true) {
    print("Ange regnummer:");
    String licensePlate = stdin.readLineSync()!;

    // Finns licensePlate i repo?
    Vehicle? existingVehicle;

    try {
      existingVehicle =
          vehicleRepository.getVehicleByLicensePlate(licensePlate);
    } catch (e) {
      existingVehicle = null;
    }
    if (existingVehicle != null) {
      // Om id redan finns, testa ett nytt
      print("Fordon är redan upplagt. Försök igen med ett nytt ID.");
    } else {
      // Fortsätt med övrig inläsning

      print("Ange type av fordon, ex bil, motorcyckel:");
      String vehicleType = stdin.readLineSync()!;

      print("Ange ägare av fordon:");
      String name = stdin.readLineSync()!;

      // print("personnummer  ddmmår:");

      String ssn;
      do {
        print("personnummer  ddmmår:");
        ssn = stdin.readLineSync()!;
        if (!ssnFormat.hasMatch(ssn)) {
          print("Ogiltigt personnummer (YYMMDD). Försök igen.");
        }
      } while (!ssnFormat.hasMatch(ssn));

      //skapa nytt personobjekt
      Person person = Person(name: name, ssn: ssn);

      personRepository.add(person);

      vehicleRepository.addVehicle(Vehicle(licensePlate, vehicleType, person));
      print("Fordon adderat");
      break;
    }
  }
}

void showVehicles() {
  List<Vehicle> allVehicles = vehicleRepository.getAllVehicles();

  if (allVehicles.isEmpty) {
    print("Inga fordon registrerade.");
  } else {
    print("Lista över alla personer:");
    for (Vehicle vehicle in allVehicles) {
      print("licenspplate: ${vehicle.licensePlate}");
      print("Ägare: ${vehicle.owner.name}");
      print("Ägarens personnummer: ${vehicle.owner.ssn}");
    }
  }
}

void deleteVehicle() {
  print("Ange registreringsnummer (eller 'exit' för att avsluta):");
  String licensePlate = stdin.readLineSync()!;

  try {
    Vehicle? vehicleToDelete =
        vehicleRepository.getVehicleByLicensePlate(licensePlate);

    if (vehicleToDelete != null) {
      vehicleRepository.deleteVehicle(vehicleToDelete);
      print("Fordon '$licensePlate' borttaget.");
    } else {
      print("Registreringsnummer ej hittat.");
    }
  } catch (e) {
    print("Ett fel uppstod vid borttagning: $e");
  }
}
