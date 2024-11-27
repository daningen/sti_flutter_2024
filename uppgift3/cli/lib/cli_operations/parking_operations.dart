import 'dart:io';

import 'package:cli/repositories/parking_repository.dart';
import 'package:cli/repositories/parking_space_repository.dart';
import 'package:cli/repositories/vehicle_repository.dart';
import 'package:cli/utils/date_time_formatter.dart';
import 'package:cli/utils/validator.dart';
import 'package:cli_shared/cli_shared.dart';

ParkingRepository repository = ParkingRepository();
ParkingSpaceRepository parkingSpaceRepository = ParkingSpaceRepository();
VehicleRepository vehicleRepository = VehicleRepository();

class ParkingOperations {
  static Future create() async {
    try {
      // Step 1: Fetch all sessions and filter for ongoing sessions (no endTime)
      // because ongoing parkings can't be parked again
      List<Parking> allSessions = await repository.getAll();
      List<Parking> ongoingSessions =
          allSessions.where((session) => session.endTime == null).toList();

      // Step 2: Fetch all vehicles and filter out those with ongoing parking sessions
      // because I can park the same vehicle twice at the same time
      List<Vehicle> allVehicles = await vehicleRepository.getAll();
      List<Vehicle> availableVehicles = allVehicles.where((vehicle) {
        return !ongoingSessions
            .any((session) => session.vehicle.target?.id == vehicle.id);
      }).toList();

      if (availableVehicles.isEmpty) {
        print('No available vehicles without ongoing parking sessions.');
        return;
      }

      print('Available vehicles:');
      for (int i = 0; i < availableVehicles.length; i++) {
        final owner = availableVehicles[i].owner.target;
        final ownerName = owner?.name ?? 'Unknown';
        print(
            '${i + 1}. License Plate: ${availableVehicles[i].licensePlate}, Owner: $ownerName');
      }

      print('Pick a vehicle by index:');
      String? vehicleInput = stdin.readLineSync();
      if (!Validator.isIndex(vehicleInput, availableVehicles)) {
        print('Invalid vehicle selection.');
        return;
      }
      Vehicle selectedVehicle = availableVehicles[int.parse(vehicleInput!) - 1];

      // Step 3: Fetch all parking spaces and filter out those occupied in ongoing sessions
      // because I cant choose a parking space that is already occupied
      List<ParkingSpace> allParkingSpaces =
          await parkingSpaceRepository.getAll();
      List<ParkingSpace> availableParkingSpaces =
          allParkingSpaces.where((space) {
        return !ongoingSessions
            .any((session) => session.parkingSpace.target?.id == space.id);
      }).toList();

      if (availableParkingSpaces.isEmpty) {
        print('No available parking spaces. Please try again later.');
        return;
      }

      print('Available parking spaces:');
      for (int i = 0; i < availableParkingSpaces.length; i++) {
        print(
            '${i + 1}. Address: ${availableParkingSpaces[i].address}, Price per Hour: ${availableParkingSpaces[i].pricePerHour}');
      }

      print('Pick a parking space by index:');
      String? spaceInput = stdin.readLineSync();
      if (!Validator.isIndex(spaceInput, availableParkingSpaces)) {
        print('Invalid parking space selection.');
        return;
      }
      ParkingSpace selectedParkingSpace =
          availableParkingSpaces[int.parse(spaceInput!) - 1];

      // Create the Parking object with selected vehicle and parking space
      Parking parking = Parking(startTime: DateTime.now());
      parking.setDetails(selectedVehicle, selectedParkingSpace);
      print("4. send the parking request with the Parking object");
      await repository.create(parking);
      print('Parking created successfully.');
    } catch (e) {
      print('Error while creating parking: $e');
    }
  }

  static Future update() async {
    try {
      // Retrieve all existing parkings
      List<Parking> allParkings = await repository.getAll();
      if (allParkings.isEmpty) {
        print('No parking sessions available for update.');
        return;
      }

      print('Pick a parking session to update:');
      for (int i = 0; i < allParkings.length; i++) {
        print(
            '${i + 1}. Vehicle License Plate: ${allParkings[i].vehicle.target?.licensePlate ?? 'Unknown'}');
      }

      String? input = stdin.readLineSync();
      if (!Validator.isIndex(input, allParkings)) {
        print('Invalid selection.');
        return;
      }

      int index = int.parse(input!) - 1;
      Parking parking = allParkings[index];

      // Fetch and display available parking spaces for updating
      List<ParkingSpace> allParkingSpaces =
          await parkingSpaceRepository.getAll();
      if (allParkingSpaces.isEmpty) {
        print('No parking spaces available.');
        return;
      }

      print('Available parking spaces:');
      for (int i = 0; i < allParkingSpaces.length; i++) {
        print(
            '${i + 1}. Address: ${allParkingSpaces[i].address}, Price per Hour: ${allParkingSpaces[i].pricePerHour}');
      }

      print('Pick a new parking space by index:');
      String? spaceInput = stdin.readLineSync();

      if (!Validator.isIndex(spaceInput, allParkingSpaces)) {
        print('Invalid parking space selection.');
        return;
      }

      int selectedSpaceIndex = int.parse(spaceInput!) - 1;
      ParkingSpace selectedParkingSpace = allParkingSpaces[selectedSpaceIndex];

      parking.setDetails(parking.vehicle.target!, selectedParkingSpace);

      await repository.update(parking.id, parking);
      print('Parking updated successfully.');
    } catch (e) {
      print('Failed to update parking: $e');
    }
  }

  static Future list() async {
    try {
      List<Parking> allParkings = await repository.getAll();
      for (int i = 0; i < allParkings.length; i++) {
        final vehicle = allParkings[i].vehicle.target;
        final parkingSpace = allParkings[i].parkingSpace.target;

        final startTimeFormatted =
            DateTimeFormatter.formatDate(allParkings[i].startTime);
        final endTimeFormatted = allParkings[i].endTime != null
            ? DateTimeFormatter.formatDate(allParkings[i].endTime!)
            : 'Ongoing';

        final durationText = DateTimeFormatter.calculateDuration(
            allParkings[i].startTime, allParkings[i].endTime);

        print(
            '${i + 1}. Vehicle License Plate: ${vehicle?.licensePlate ?? 'Unknown'}, '
            'Address: ${parkingSpace?.address ?? 'Unknown'}, '
            'Start Time: $startTimeFormatted, '
            'End Time: $endTimeFormatted, '
            'Duration: $durationText');
      }
    } catch (e) {
      print('Failed to retrieve parkings: $e');
    }
  }

  static Future delete() async {
    try {
      List<Parking> allParkings = await repository.getAll();
      if (allParkings.isEmpty) {
        print('No parking sessions available for deletion.');
        return;
      }

      print('Pick an index to delete: ');
      for (int i = 0; i < allParkings.length; i++) {
        final vehicle = allParkings[i].vehicle.target;
        print(
            '${i + 1}. Vehicle License Plate: ${vehicle?.licensePlate ?? 'Unknown'}');
      }

      String? input = stdin.readLineSync();
      if (!Validator.isIndex(input, allParkings)) {
        print('Invalid selection.');
        return;
      }

      int index = int.parse(input!) - 1;
      await repository.delete(allParkings[index].id);
      print('Parking deleted successfully.');
    } catch (e) {
      print('Failed to delete parking: $e');
    }
  }

  static Future stop() async {
    try {
      List<Parking> allParkings = await repository.getAll();
      if (allParkings.isEmpty) {
        print('No parking sessions available to stop.');
        return;
      }

      print('Pick an index to stop the session: ');
      for (int i = 0; i < allParkings.length; i++) {
        final vehicle = allParkings[i].vehicle.target;
        print(
            '${i + 1}. Vehicle License Plate: ${vehicle?.licensePlate ?? 'Unknown'}, Start Time: ${allParkings[i].startTime}');
      }

      String? input = stdin.readLineSync();
      if (!Validator.isIndex(input, allParkings)) {
        print('Invalid selection.');
        return;
      }

      int index = int.parse(input!) - 1;
      await repository.stop(allParkings[index].id);
      print('Parking session stopped successfully.');
    } catch (e) {
      print('Failed to stop parking: $e');
    }
  }
}
