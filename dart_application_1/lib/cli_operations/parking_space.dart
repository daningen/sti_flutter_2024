import 'dart:io';

import 'package:dart_application_1/globals.dart';
import 'package:dart_application_1/models/parking_space.dart';

void addParkingSpace() {
  while (true) {
    print("Ange parkeringsplatsens ID:");
    String id = stdin.readLineSync()!;

    // Finns id i repo?
    ParkingSpace? existingSpace;

    try {
      existingSpace = parkingSpaceRepository.getParkingSpaceById(id);
    } catch (e) {
      existingSpace = null;
    }

    if (existingSpace != null) {
      // Om id redan finns, testa ett nytt
      print("ID '$id' finns redan. Försök igen med ett nytt ID.");
    } else {
      // Fortsätt med övrig inläsning
      print("Ange adress för parkeringsplatsen:");
      String address = stdin.readLineSync()!;

      print("Ange pris per timme för parkeringsplatsen:");
      int pricePerHour =
          int.parse(stdin.readLineSync()!); // Treat as an integer

      // Skapa ParkingSpace objekt
      ParkingSpace parkingSpace = ParkingSpace(id, address, pricePerHour);

      // Lägg till objekt i repo
      parkingSpaceRepository.addParkingSpace(parkingSpace);

      print(
          "Parkeringsplats tillagd: ID: ${parkingSpace.id}, Adress: ${parkingSpace.address}, Pris: ${parkingSpace.pricePerHour} kr/timme");
      break;
    }
  }
}

void showParkingSpaces() {
  List<ParkingSpace> allParkingSpaces =
      parkingSpaceRepository.getAllParkingSpaces();

  if (allParkingSpaces.isEmpty) {
    print("Inga parkeringsplatser registrerade.");
  } else {
    print("Lista över alla parkeringsplatser:");

    for (ParkingSpace parkingSpace in allParkingSpaces) {
      print(
          "ID: ${parkingSpace.id}, Adress: ${parkingSpace.address}, pris:  ${parkingSpace.pricePerHour}");
    }
  }
}

void updateParkingSpace() {
  print("Ange id för platsen du vill uppdatera");
  String parkingSpaceId = stdin.readLineSync()!;
  print("Ange det nya priset");
  String newPrice = stdin.readLineSync()!;

  try {
    ParkingSpace? parkingSpaceToUpdate =
        parkingSpaceRepository.getParkingSpaceById(parkingSpaceId);
    int parsedPrice = int.parse(newPrice);

    if (parkingSpaceToUpdate != null) {
      int index = parkingSpaceRepository.items.indexOf(parkingSpaceToUpdate);
      parkingSpaceToUpdate.pricePerHour = parsedPrice;
      parkingSpaceRepository.items[index] = parkingSpaceToUpdate;
      print("Parkeringsplats uppdaterad");
    } else {
      print("Hittade ingen parkeringsplats med id: $parkingSpaceId");
    }
  } on StateError catch (e) {
    print("Ett fel uppstod: $e. Kontrollera id.");
  } on Exception catch (e) {
    print("Ett oväntat fel uppstod: $e");
  }
}

void deleteParkingSpace() {
  print("Ange parkeringsplats som du vill ta bort:");
  String parkingSpaceId = stdin.readLineSync()!;

  ParkingSpace? parkingSpaceToDelete =
      parkingSpaceRepository.getParkingSpaceById(parkingSpaceId);

  if (parkingSpaceToDelete != null) {
    parkingSpaceRepository.deleteParkingSpace(parkingSpaceToDelete);
    print("Plats med id '$parkingSpaceId' borttaget");
  } else {
    print("Parkeringsplats'$parkingSpaceId' hittades inte.");
  }
}
