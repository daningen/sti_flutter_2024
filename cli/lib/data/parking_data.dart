// lib/data/parking_data.dart
import 'package:cli/models/person.dart';
import 'package:cli/models/vehicle.dart';
import 'package:cli/models/parking_space.dart';
import 'package:cli/models/parking.dart';
import 'package:cli/utils/generate_random_licenseplate.dart';
import 'package:cli/utils/generate_random_ssn.dart';

int nextParkingId = 1;

Parking generateDummyParking() {
  // Generate random license plate and SSN
  String randomLicensePlate = generateRandomLicensePlate();
  String randomSSN = generateRandomSSN();

  // Create vehicle, parking space, and parking objects
  Vehicle vehicle = Vehicle(
    id: 1,
    licensePlate: randomLicensePlate,
    vehicleType: 'bil',
    owner: Person(id: 1, name: 'Kim Karlsson', ssn: randomSSN),
  );

  ParkingSpace parkingSpace = ParkingSpace(
    id: 101,
    address: 'Sveavägen 6',
    pricePerHour: 20,
  );

  Parking parking = Parking(
    id: nextParkingId++,
    vehicle: vehicle,
    parkingSpace: parkingSpace,
    startTime: DateTime.now(),
  );

  return parking;
}
