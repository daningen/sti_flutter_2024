import 'dart:io';
import 'package:dart_application_1/globals.dart';
import 'package:dart_application_1/models/person.dart';
import 'package:dart_application_1/models/vehicle.dart';

//update vehicle
void updateVehicle() {
  print("uppdatera fordon");
//   print("Ange personnummer för personen du vill uppdatera:");
//   String licensePlate = stdin.readLineSync()!;

//   Person? vehicleToUpdate =
//       vehicleRepository.getVehicleByLicensePlate(licensePlate);

//   if (vehicleToUpdate != null) {
//     print("Ange nytt namn:");
//     String newName = stdin.readLineSync()!;

//     Person newPerson = Person(name: newName, ssn: personToUpdate.ssn);
//     personRepository.update(personToUpdate, newPerson);
//     print("Personen uppdaterad!");
//   }
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

  // Initialize the repository
  // VehicleRepository vehicleRepository = VehicleRepository([]);

  // Create a Person object using named parameters
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
