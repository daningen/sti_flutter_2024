import 'package:dart_application_1/models/vehicle.dart';
import 'package:dart_application_1/repositories/repository.dart';

class VehicleRepository extends Repository<Vehicle> {
  VehicleRepository(this._items);

  List<Vehicle> get items => _items;

  final List<Vehicle> _items;

  void addVehicle(Vehicle vehicle) {
    _items.add(vehicle);
  }

  Vehicle? getVehicleByLicensePlate(String licensePlate) {
    return _items.firstWhere((vehicle) => vehicle.licensePlate == licensePlate);
  }

  List<Vehicle> getAllVehicles() {
    return _items;
  }

  void deleteVehicle(Vehicle licensePlate) {
    _items.remove(licensePlate);
  }
}
