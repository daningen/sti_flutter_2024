import 'package:cli/repositories/parking_space_repository.dart';
import 'package:cli/repositories/person_repository.dart';
import 'package:cli/repositories/vehicle_repository.dart';

import 'package:cli/repositories/parking_repository.dart';

// alla repositories
VehicleRepository vehicleRepository =
    VehicleRepository(); // Initialize with an empty list
PersonRepository personRepository =
    PersonRepository(); // Initialize with an empty list
ParkingSpaceRepository parkingSpaceRepository =
    ParkingSpaceRepository([]); // Initialize with an empty list
ParkingRepository parkingRepository =
    ParkingRepository();   // Initialize with an empty list
