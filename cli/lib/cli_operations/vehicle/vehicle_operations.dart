import 'dart:convert';
import 'dart:io';
import 'package:cli/globals.dart';
import 'package:cli/models/person.dart';
import 'package:cli/models/vehicle.dart';

Future<void> updateVehicle() async {
  print("Ange registreringsnummer för fordonet du vill uppdatera:");
  String licensePlate = stdin.readLineSync()!;
  //sök fordon
  Vehicle? vehicleToUpdate =
      await vehicleRepository.getVehicleByLicensePlate(licensePlate);

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

Future<void> addVehicle() async {
  print("in addVehicle function");
  final url = Uri.parse('http://localhost:8080/vehicles');
  // ignore: prefer_typing_uninitialized_variables
  var http;
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'licensePlate': 'ABC123',
      'vehicleType': 'Car',
      'owner': {'name': 'John Doe', 'ssn': '0101011234'}
    }),
  );

  if (response.statusCode == 201) {
    print('Vehicle added successfully');
  } else {
    print('Failed to add vehicle: ${response.body}');
  }
}
// Future<void> addVehicle() async {
//   while (true) {
//     print("Ange regnummer:");
//     String licensePlate = stdin.readLineSync()!;

//     // Check if the vehicle already exists
//     Vehicle? existingVehicle =
//         await vehicleRepository.getVehicleByLicensePlate(licensePlate);

//     if (existingVehicle != null) {
//       print("Fordon är redan upplagt. Försök igen med ett nytt ID.");
//     } else {
//       // Proceed with adding a new vehicle
//       print("Ange typ av fordon, ex bil, motorcyckel:");
//       String vehicleType = stdin.readLineSync()!;

//       print("Ange ägare av fordon:");
//       String name = stdin.readLineSync()!;

//       String ssn;
//       do {
//         print("personnummer  ddmmår:");
//         ssn = stdin.readLineSync()!;
//         if (!ssnFormat.hasMatch(ssn)) {
//           print("Ogiltigt personnummer (YYMMDD). Försök igen.");
//         }
//       } while (!ssnFormat.hasMatch(ssn));

//       // Create a new person object
//       Person person = Person(name: name, ssn: ssn);
//       personRepository.add(person);

//       // Create a new vehicle object
//       Vehicle newVehicle = Vehicle(licensePlate, vehicleType, person);

//       // Add the vehicle to the repository (send a POST request)

//       await vehicleRepository.add(newVehicle);
//       print("Fordon adderat");
//       break;
//     }
//   }
// }

void showVehicles() async {
  List<Vehicle> allVehicles = await vehicleRepository.getAll();

  if (allVehicles.isEmpty) {
    print("Inga fordon registrerade.");
  } else {
    print("Lista över alla personer:");
    for (Vehicle vehicle in allVehicles) {
      print("licensplate: ${vehicle.licensePlate}");
      print("Ägare: ${vehicle.owner.name}");
      print("Ägarens personnummer: ${vehicle.owner.ssn}");
    }
  }
}

Future<void> deleteVehicle() async {
  print("Ange registreringsnummer (eller 'exit' för att avsluta):");
  String licensePlate = stdin.readLineSync()!;

  try {
    Vehicle? vehicleToDelete =
        await vehicleRepository.getVehicleByLicensePlate(licensePlate);

    if (vehicleToDelete != null) {
      await vehicleRepository.delete(vehicleToDelete);
      print("Fordon '$licensePlate' borttaget.");
    } else {
      print("Registreringsnummer ej hittat.");
    }
  } catch (e) {
    print("Ett fel uppstod vid borttagning: $e");
  }
}
