import 'package:cli/models/parking.dart';
import 'package:cli/repositories/repository.dart';

class ParkingRepository extends Repository<Parking> {
  // Asynchronous method to get a parking entry by vehicle license plate
  Future<Parking?> getByLicensePlate(String licensePlate) async {
    List<Parking> allParkings = await getAll();
    try {
      return allParkings.firstWhere(
        (parking) => parking.vehicle.licensePlate == licensePlate,
      );
    } catch (e) {
      return null; // Return null if no parking is found
    }
  }

  // Asynchronous method to get a parking entry by parking id
  Future<Parking?> getById(int id) async {
    List<Parking> allParkings = await getAll();
    try {
      return allParkings.firstWhere(
        (parking) => parking.id == id,
      );
    } catch (e) {
      return null; // Return null if no parking is found
    }
  }

  // Method to stop parking by updating the end time using the parking id
  Future<void> stopParking(int id) async {
    List<Parking> allParkings = await getAll();
    var index = allParkings.indexWhere((p) => p.id == id);

    if (index != -1) {
      // Update the existing parking entry with the current end time
      allParkings[index].endParkingSession();
    } else {
      throw Exception("Parking session not found");
    }
  }
}
