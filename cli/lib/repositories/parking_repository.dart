import 'package:cli/models/parking.dart';
import 'package:cli/repositories/repository.dart';

class ParkingRepository extends Repository<Parking> {
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

  Future<void> stopParking(int id) async {
    List<Parking> allParkings = await getAll();
    var index = allParkings.indexWhere((p) => p.id == id);

    if (index != -1) {
      // uppdatera parkering med sluttid
      allParkings[index].endParkingSession();
    } else {
      throw Exception("Parking session not found");
    }
  }
}
