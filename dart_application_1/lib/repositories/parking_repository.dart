import 'package:dart_application_1/models/parking.dart';
import 'package:dart_application_1/repositories/repository.dart';

class ParkingRepository extends Repository<Parking> {
  // Method to get a parking entry by vehicle license plate
  Parking? getByLicensePlate(String licensePlate) {
    return getAll()
        .firstWhere((parking) => parking.vehicle.licensePlate == licensePlate);
  }

  // Method to update the parking end time
  void stopParking(Parking parking) {
    var index = getAll().indexWhere(
        (p) => p.vehicle.licensePlate == parking.vehicle.licensePlate);
    if (index != -1) {
      getAll()[index] = Parking(
        vehicle: parking.vehicle,
        parkingSpace: parking.parkingSpace,
        startTime: parking.startTime,
        endTime: DateTime.now(), // End the parking session
      );
    }
  }

  // Other methods are inherited from Repository<T>
}
