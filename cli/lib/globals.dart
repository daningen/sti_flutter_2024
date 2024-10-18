import 'package:cli/repositories/parking_space_repository.dart';
import 'package:cli/repositories/person_repository.dart';
import 'package:cli/repositories/vehicle_repository.dart';

// Declare and initialize your repositories
VehicleRepository vehicleRepository =
    VehicleRepository(); // Initialize with an empty list
PersonRepository personRepository = PersonRepository([]);
ParkingSpaceRepository parkingSpaceRepository = ParkingSpaceRepository([]);
// ParkingRepository parkingRepository = ParkingRepository([]);
