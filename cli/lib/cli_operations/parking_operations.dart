import 'dart:io';
import 'package:cli/models/parking.dart';
import 'package:cli/models/parking_space.dart';
import 'package:cli/models/person.dart';
import 'package:cli/models/vehicle.dart';
import 'package:cli/repositories/parking_repository.dart';

ParkingRepository parkingRepository = ParkingRepository();

int nextVehicleId = 1; // Placeholder for vehicle id increment
int nextParkingSpaceId = 1; // Placeholder for parking space id increment

void startParking() async {
  print("Ange regnummer:");
  String licensePlate = stdin.readLineSync()!;

  print("Ange typ av fordon (ex. bil, motorcykel):");
  String vehicleType = stdin.readLineSync()!;

  print("Ange ägare av fordon:");
  String ownerName = stdin.readLineSync()!;

  print("Ange personnummer (ddmmyy):");
  String ssn = stdin.readLineSync()!;

  print("Ange parkeringsplatsens adress:");
  String parkingSpaceAddress = stdin.readLineSync()!;

  print("Ange pris per timme:");
  int pricePerHour = int.parse(stdin.readLineSync()!);

  // Skapa fordon och parkingspace objekt
  Vehicle vehicle = Vehicle(
    id: nextVehicleId++, // Increment ID for each new vehicle
    licensePlate: licensePlate,
    vehicleType: vehicleType,
    owner: Person(id: 1, name: ownerName, ssn: ssn),
  );

  ParkingSpace parkingSpace = ParkingSpace(
    id: nextParkingSpaceId++, // Increment ID for each new parking space
    address: parkingSpaceAddress,
    pricePerHour: pricePerHour,
  );

  // Skapa och starta parkering
  Parking parking = Parking(
    id: 1, // You should generate a unique id or manage it
    vehicle: vehicle,
    parkingSpace: parkingSpace,
    startTime: DateTime.now(),
    endTime: null, // EndTime is null while parking is ongoing
  );

  parkingRepository.add(parking);
  print("Parkering startad för fordon ${vehicle.licensePlate}");
}

void showParking() async {
  print("Ange fordonets registreringsnummer:");
  String licensePlate = stdin.readLineSync()!;

  Parking? parking = await parkingRepository.getByLicensePlate(licensePlate);
  if (parking != null) {
    print("Registreringsnummer: ${parking.vehicle.licensePlate}");
    print("Ägare: ${parking.vehicle.owner.name}");
    print("Starttid: ${parking.startTime}");
    if (parking.endTime != null) {
      print("Sluttid: ${parking.endTime}");
    } else {
      print("Sluttid: Parkeringen pågår fortfarande.");
    }
  } else {
    print("Ingen parkering hittad för registreringsnummer: $licensePlate");
  }
}

void updateParking() async {
  print("Ange registreringsnummer för att uppdatera parkeringen:");
  String licensePlate = stdin.readLineSync()!;

  // Await the async call to getByLicensePlate
  Parking? parking = await parkingRepository.getByLicensePlate(licensePlate);

  if (parking != null) {
    print("Ange ny parkeringsplatsens adress:");
    String newParkingSpaceAddress = stdin.readLineSync()!;

    print("Ange nytt pris per timme:");
    int newPricePerHour = int.parse(stdin.readLineSync()!);

    // Create updated parking space
    ParkingSpace newParkingSpace = ParkingSpace(
      id: parking.parkingSpace.id, // Use existing parking space id
      address: newParkingSpaceAddress,
      pricePerHour: newPricePerHour,
    );

    // Create updated parking object
    Parking updatedParking = Parking(
      id: parking.id, // Use the same id as the original parking
      vehicle: parking.vehicle,
      parkingSpace: newParkingSpace,
      startTime: parking.startTime,
      endTime: parking.endTime, // Keep the endTime unchanged
    );

    // Await the update in repository
    await parkingRepository.update(parking, updatedParking);
    print("Parkering uppdaterad.");
  } else {
    print("Ingen parkering hittades för registreringsnummer: $licensePlate");
  }
}

void stopParkingSpace() async {
  print("Ange registreringsnummer för att avsluta parkeringen:");
  String licensePlate = stdin.readLineSync()!;

  // Await the result of getByLicensePlate since it's asynchronous
  Parking? parking = await parkingRepository.getByLicensePlate(licensePlate);

  if (parking != null) {
    await parkingRepository
        .stopParking(parking.id); // Use the id to stop parking
    print("Parkeringen avslutad för fordon ${parking.vehicle.licensePlate}");
  } else {
    print("Ingen parkering hittades för registreringsnummer: $licensePlate");
  }
}
