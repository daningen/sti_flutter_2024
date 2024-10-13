import 'dart:io';
import 'package:intl/intl.dart';

import 'package:dart_application_1/models/person.dart';
import 'package:dart_application_1/models/vehicle.dart';
import 'package:dart_application_1/models/parking.dart';
import 'package:dart_application_1/models/parking_space.dart';
import 'package:dart_application_1/repositories/parking_repository.dart';

ParkingRepository parkingRepository = ParkingRepository();

void startParking() {
  print("Ange regnummer:");
  String licensePlate = stdin.readLineSync()!;

  print("Ange typ av fordon (ex. bil, motorcykel):");
  String vehicleType = stdin.readLineSync()!;

  print("Ange ägare av fordon:");
  String ownerName = stdin.readLineSync()!;

  print("Ange personnummer (ddmmyy):");
  String ssn = stdin.readLineSync()!;

  print("Ange parkeringsplatsens id:");
  String parkingSpaceId = stdin.readLineSync()!;

  print("Ange parkeringsplatsens adress:");
  String parkingSpaceAddress = stdin.readLineSync()!;

  print("Ange pris per timme:");
  int pricePerHour = int.parse(stdin.readLineSync()!);

  //skapa fordon och parkingspace objekt
  Vehicle vehicle =
      Vehicle(licensePlate, vehicleType, Person(name: ownerName, ssn: ssn));
  ParkingSpace parkingSpace =
      ParkingSpace(parkingSpaceId, parkingSpaceAddress, pricePerHour);

  //Skapa och starta parkering
  Parking parking = Parking(
    vehicle: vehicle,
    parkingSpace: parkingSpace,
    startTime: DateTime.now(),
    endTime: null, //endTime sätts till null så länge parkering pågår
  );

  parkingRepository.add(parking);
  print("Parkering startad för fordon ${vehicle.licensePlate}");
}

void showParking() {
  print("Ange fordonets registreringsnummer:");
  String licensePlate = stdin.readLineSync()!;

  Parking? parking = parkingRepository.getByLicensePlate(licensePlate);
  if (parking != null) {
    print("Registreringsnummer: ${parking.vehicle.licensePlate}");
    print("Ägare: ${parking.vehicle.owner.name}");

    //formatera datum
    print(
        "Starttid: ${DateFormat('yyyy-MM-dd HH:mm').format(parking.startTime)}");

    print("Parkeringsplats: ${parking.parkingSpace.address}");

    //formatera endTime om det inte är null observer ! efter endTime som kontrollera att det inte är null
    if (parking.endTime != null) {
      print(
          "Sluttid: ${DateFormat('yyyy-MM-dd HH:mm').format(parking.endTime!)}");
    } else {
      print("Sluttid: Parkeringen pågår fortfarande.");
    }
  } else {
    print(
        "Inget parkeringssession hittat för registreringsnummer: $licensePlate");
  }
}

void updateParking() {
  print("Ange registreringsnummer för att uppdatera parkeringen:");
  String licensePlate = stdin.readLineSync()!;

  Parking? parking = parkingRepository.getByLicensePlate(licensePlate);
  if (parking != null) {
    print("Ange ny parkeringsplatsens id:");
    String newParkingSpaceId = stdin.readLineSync()!;

    print("Ange ny parkeringsplatsens adress:");
    String newParkingSpaceAddress = stdin.readLineSync()!;

    print("Ange nytt pris per timme:");
    int newPricePerHour = int.parse(stdin.readLineSync()!);

    //uppdaterat parkingspace
    ParkingSpace newParkingSpace = ParkingSpace(
        newParkingSpaceId, newParkingSpaceAddress, newPricePerHour);

    //uppdatera
    Parking updatedParking = Parking(
      vehicle: parking.vehicle,
      parkingSpace: newParkingSpace,
      startTime: parking.startTime,
      endTime: parking.endTime, // Keep the endTime unchanged
    );

    parkingRepository.update(parking, updatedParking);
    print("Parkering uppdaterad.");
  } else {
    print("Ingen parkering hittades för registreringsnummer: $licensePlate");
  }
}

void stopParkingSpace() {
  print("Ange registreringsnummer för att avsluta parkeringen:");
  String licensePlate = stdin.readLineSync()!;

  Parking? parking = parkingRepository.getByLicensePlate(licensePlate);
  if (parking != null) {
    parkingRepository.stopParking(parking);
    print("Parkeringen avslutad för fordon ${parking.vehicle.licensePlate}");
  } else {
    print("Ingen parkering hittades för registreringsnummer: $licensePlate");
  }
}
