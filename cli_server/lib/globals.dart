import 'package:cli_server/parking_repository.dart';
import 'package:cli_server/parking_space_repository.dart';
import 'package:cli_server/person_repository.dart';
import 'package:cli_server/vehicle_repository.dart';

// Declare and initialize your repositories
VehicleRepository vehicleRepository =
    VehicleRepository(); // Initialize with an empty list
PersonRepository personRepository =
    PersonRepository(); // Initialize with an empty list
ParkingSpaceRepository parkingSpaceRepository =
    ParkingSpaceRepository([]); // Initialize with an empty list
ParkingRepository parkingRepository =
    ParkingRepository(); // Initialize with an empty list

void printGlobalsStatus() {
  print(
      'Globals initialized: vehicleRepository and personRepository are ready to use.');
}
