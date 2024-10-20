import 'package:cli/models/vehicle.dart';
import 'package:cli/repositories/repository.dart';

class VehicleRepository extends Repository<Vehicle> {
  List<Vehicle> get allItems => items;

  // Search vehicle by license plate
  Future<Vehicle?> getVehicleByLicensePlate(String licensePlate) async {
    try {
      return items
          .firstWhere((vehicle) => vehicle.licensePlate == licensePlate);
    } catch (e) {
      return null; // Return null if no vehicle is found
    }
  }

  // Search vehicle by id
  Future<Vehicle?> getVehicleById(int id) async {
    try {
      return items.firstWhere((vehicle) => vehicle.id == id);
    } catch (e) {
      return null; // Return null if no vehicle is found
    }
  }

  // Delete vehicle by id
  Future<void> deleteVehicleById(int id) async {
    items.removeWhere((vehicle) => vehicle.id == id);
  }

  // Update vehicle by id
  Future<void> updateVehicle(int id, Vehicle newVehicle) async {
    var index = items.indexWhere((vehicle) => vehicle.id == id);
    if (index != -1) {
      items[index] = newVehicle;
    } else {
      throw Exception("Vehicle not found");
    }
  }
}
