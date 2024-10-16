import 'package:cli/models/parking.dart';
import 'package:cli/repositories/repository.dart';

class ParkingRepository extends Repository<Parking> {
  // Asynchronous method to get a parking entry by vehicle license plate
  Future<Parking?> getByLicensePlate(String licensePlate) async {
    List<Parking> allParkings = await getAll();
    try {
      return allParkings.firstWhere(
          (parking) => parking.vehicle.licensePlate == licensePlate);
      // orElse: () => null); // Return null directly
    } catch (e) {
      return null;
    }
  }

  // Method to stop parking by updating the end time
  Future<void> stopParking(Parking parking) async {
    List<Parking> allParkings = await getAll();
    var index = allParkings.indexWhere(
        (p) => p.vehicle.licensePlate == parking.vehicle.licensePlate);
    if (index != -1) {
      allParkings[index] = Parking(
        vehicle: parking.vehicle,
        parkingSpace: parking.parkingSpace,
        startTime: parking.startTime,
        endTime: DateTime.now(), // End the parking session
      );
    }
  }
}
