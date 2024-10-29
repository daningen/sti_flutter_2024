import 'dart:io';
import 'package:cli/repositories/parking_repository.dart';
import 'package:cli/repositories/parking_space_repository.dart';
import 'package:cli/repositories/vehicle_repository.dart';
import 'package:cli/utils/validator.dart';
import 'package:cli_shared/cli_shared.dart';

ParkingRepository repository = ParkingRepository();
ParkingSpaceRepository parkingSpaceRepo = ParkingSpaceRepository();
VehicleRepository vehicleRepo = VehicleRepository();

class ParkingOperations {
  static Future create() async {
    List<Vehicle> allVehicles = await vehicleRepo.getAll();
    if (allVehicles.isEmpty) {
      print(
          'No vehicles available. Please add one before creating a parking session.');
      return;
    }

    print('Available vehicles:');
    for (int i = 0; i < allVehicles.length; i++) {
      print('${i + 1}. License Plate: ${allVehicles[i].licensePlate}');
    }

    print('Pick a vehicle by index:');
    String? vehicleInput = stdin.readLineSync();
    if (!Validator.isIndex(vehicleInput, allVehicles)) {
      print('Invalid vehicle selection.');
      return;
    }

    int selectedVehicleIndex = int.parse(vehicleInput!) - 1;
    Vehicle selectedVehicle = allVehicles[selectedVehicleIndex];

    List<ParkingSpace> allParkingSpaces = await parkingSpaceRepo.getAll();
    if (allParkingSpaces.isEmpty) {
      print(
          'No parking spaces available. Please add one before creating a parking session.');
      return;
    }

    print('Available parking spaces:');
    for (int i = 0; i < allParkingSpaces.length; i++) {
      print('${i + 1}. Address: ${allParkingSpaces[i].address}');
    }

    print('Pick a parking space by index:');
    String? spaceInput = stdin.readLineSync();
    if (!Validator.isIndex(spaceInput, allParkingSpaces)) {
      print('Invalid parking space selection.');
      return;
    }

    int selectedSpaceIndex = int.parse(spaceInput!) - 1;
    ParkingSpace selectedParkingSpace = allParkingSpaces[selectedSpaceIndex];

    Parking parking = Parking(startTime: DateTime.now());
    parking.setDetails(selectedVehicle, selectedParkingSpace);

    await repository.create(parking);
    print('Parking created successfully.');
  }

  static Future list() async {
    // Code for listing all parking sessions
  }

  static Future update() async {
    // Code for updating a parking session
  }

  static Future stop() async {
    // Code for stopping a parking session
  }
}
