import 'dart:io';

import 'package:cli/globals.dart';
import 'package:cli/models/parking_space.dart';

// Function to add a parking space
Future<void> addParkingSpace() async {
  while (true) {
    print("Ange parkeringsplatsens ID (siffra):");
    String? inputId = stdin.readLineSync();
    if (inputId == null || int.tryParse(inputId) == null) {
      print("Ogiltigt ID. Ange ett giltigt nummer.");
      continue;
    }
    int id = int.parse(inputId);

    // Check if the ID already exists in the repo
    ParkingSpace? existingSpace = await parkingSpaceRepository.getById(id);

    if (existingSpace != null) {
      // If the ID already exists, prompt to try again
      print("ID '$id' finns redan. Försök igen med ett nytt ID.");
    } else {
      // Proceed with the rest of the input
      print("Ange adress för parkeringsplatsen:");
      String? address = stdin.readLineSync();

      print("Ange pris per timme för parkeringsplatsen:");
      String? inputPrice = stdin.readLineSync();
      if (inputPrice == null || int.tryParse(inputPrice) == null) {
        print("Ogiltigt pris. Ange ett giltigt nummer.");
        continue;
      }
      int pricePerHour = int.parse(inputPrice);

      // Create ParkingSpace object
      ParkingSpace parkingSpace = ParkingSpace(
        id: id,
        address: address ?? 'Ingen adress',
        pricePerHour: pricePerHour,
      );

      // Add the object to the repository
      await parkingSpaceRepository.add(parkingSpace);

      print(
          "Parkeringsplats tillagd: ID: ${parkingSpace.id}, Adress: ${parkingSpace.address}, Pris: ${parkingSpace.pricePerHour} kr/timme");
      break;
    }
  }
}

// Function to show all parking spaces
Future<void> showParkingSpaces() async {
  List<ParkingSpace> allParkingSpaces =
      await parkingSpaceRepository.getAllParkingSpaces();

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

// Function to update a parking space
Future<void> updateParkingSpace() async {
  print("Ange ID för platsen du vill uppdatera:");
  String? inputId = stdin.readLineSync();
  if (inputId == null || int.tryParse(inputId) == null) {
    print("Ogiltigt ID.");
    return;
  }
  int parkingSpaceId = int.parse(inputId);

  print("Ange det nya priset:");
  String? newPrice = stdin.readLineSync();
  if (newPrice == null || int.tryParse(newPrice) == null) {
    print("Ogiltigt pris.");
    return;
  }
  int parsedPrice = int.parse(newPrice);

  try {
    ParkingSpace? parkingSpaceToUpdate =
        await parkingSpaceRepository.getById(parkingSpaceId);

    if (parkingSpaceToUpdate != null) {
      // Create a new ParkingSpace object with updated price
      ParkingSpace updatedSpace = ParkingSpace(
        id: parkingSpaceToUpdate.id,
        address: parkingSpaceToUpdate.address,
        pricePerHour: parsedPrice,
      );

      await parkingSpaceRepository.update(parkingSpaceToUpdate, updatedSpace);
      print("Parkeringsplats uppdaterad");
    } else {
      print("Hittade ingen parkeringsplats med ID: $parkingSpaceId");
    }
  } catch (e) {
    print("Ett oväntat fel uppstod: $e");
  }
}

// Function to delete a parking space
Future<void> deleteParkingSpace() async {
  print("Ange parkeringsplats-ID som du vill ta bort:");
  String? inputId = stdin.readLineSync();
  if (inputId == null || int.tryParse(inputId) == null) {
    print("Ogiltigt ID.");
    return;
  }
  int parkingSpaceId = int.parse(inputId);

  ParkingSpace? parkingSpaceToDelete =
      await parkingSpaceRepository.getById(parkingSpaceId);

  if (parkingSpaceToDelete != null) {
    await parkingSpaceRepository.deleteParkingSpace(parkingSpaceToDelete);
    print("Plats med ID '$parkingSpaceId' borttaget");
  } else {
    print("Parkeringsplats med ID '$parkingSpaceId' hittades inte.");
  }
}
