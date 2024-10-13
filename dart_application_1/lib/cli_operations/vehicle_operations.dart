import 'dart:io';
import 'package:dart_application_1/globals.dart';
import 'package:dart_application_1/models/person.dart';
import 'package:dart_application_1/models/vehicle.dart';

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
  print("Ange regnummer:");
  String licensePlate = stdin.readLineSync()!;

  print("Ange type av fordon, ex bil, motorcyckel:");
  String vehicleType = stdin.readLineSync()!;

  print("Ange ägare av fordon:");
  String name = stdin.readLineSync()!;

  print("personnummer  ddmmår:");
  String ssn = stdin.readLineSync()!;

  //skapa nytt personobjekt
  Person person = Person(name: name, ssn: ssn);

  personRepository.add(person);

  vehicleRepository.addVehicle(Vehicle(licensePlate, vehicleType, person));
  print("Fordon adderat");
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
