import 'package:cli/models/vehicle.dart';
import 'package:cli/repositories/repository.dart';

class VehicleRepository extends Repository<Vehicle> {
  List<Vehicle> get allItems => items;

  Future<Vehicle?> getVehicleByLicensePlate(String licensePlate) async {
    try {
      return items
          .firstWhere((vehicle) => vehicle.licensePlate == licensePlate);
    } catch (e) {
      return null;
    }
  }
}
