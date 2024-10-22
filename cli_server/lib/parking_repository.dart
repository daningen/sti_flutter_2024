import 'package:cli_server/models/parking.dart';
import 'package:cli_server/repository.dart';

class ParkingRepository extends Repository<Parking> {
  // Get parking by license plate
  Future<Parking?> getByLicensePlate(String licensePlate) async {
    List<Parking> allParkings = await getAll();
    try {
      return allParkings.firstWhere(
        (parking) => parking.vehicle.licensePlate == licensePlate,
      );
    } catch (e) {
      return null;
    }
  }

  // Get parking by ID
  Future<Parking?> getById(int id) async {
    List<Parking> allParkings = await getAll();
    try {
      return allParkings.firstWhere(
        (parking) => parking.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  // Stop parking by license plate
  Future<void> stopParkingByLicensePlate(String licensePlate) async {
    List<Parking> allParkings = await getAll();
    var index =
        allParkings.indexWhere((p) => p.vehicle.licensePlate == licensePlate);

    if (index != -1) {
      allParkings[index].endParkingSession();
      await update(
          allParkings[index], allParkings[index]); // Ensure changes are saved
    } else {
      throw Exception(
          "Parking session not found for license plate $licensePlate");
    }
  }

  // Update parking by license plate
  Future<void> updateByLicensePlate(
      String licensePlate, Parking updatedParking) async {
    List<Parking> allParkings = await getAll();
    int index =
        allParkings.indexWhere((p) => p.vehicle.licensePlate == licensePlate);

    if (index != -1) {
      final existingParking = allParkings[index];
      await update(existingParking,
          updatedParking); // Pass both old and new parking objects
    } else {
      throw Exception(
          'Parking session not found for license plate $licensePlate');
    }
  }

  // Delete parking by license plate
  Future<void> deleteByLicensePlate(String licensePlate) async {
    List<Parking> allParkings = await getAll();
    int index =
        allParkings.indexWhere((p) => p.vehicle.licensePlate == licensePlate);

    if (index != -1) {
      allParkings.removeAt(index);
      // No need for saveAll, as you are not persisting changes to disk or DB in this case
    } else {
      throw Exception(
          'Parking session not found for license plate $licensePlate');
    }
  }
}
