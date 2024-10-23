import 'package:cli/repositories/parking_space_repository.dart';
import 'package:cli/repositories/person_repository.dart';
import 'package:cli/repositories/vehicle_repository.dart';

import 'package:cli/repositories/parking_repository.dart';

// alla repositories initieras
VehicleRepository vehicleRepository = VehicleRepository();
PersonRepository personRepository = PersonRepository();
ParkingSpaceRepository parkingSpaceRepository = ParkingSpaceRepository([]);
ParkingRepository parkingRepository = ParkingRepository();
