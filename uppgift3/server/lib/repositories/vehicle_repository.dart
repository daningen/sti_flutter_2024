import 'package:cli_server/router_config.dart';
import 'package:cli_shared/cli_shared.dart';

class VehicleRepository implements RepositoryInterface<Vehicle> {
  // Access ObjectBox store
  Box<Vehicle> vehicleBox = ServerConfig.instance.store.box<Vehicle>();

  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    vehicleBox.put(vehicle, mode: PutMode.insert);

    return vehicle;
  }

  @override
  Future<Vehicle?> getById(int id) async {
    return vehicleBox.get(id);
  }

  @override
  Future<List<Vehicle>> getAll() async {
    print("getAll now for vehicles");
    return vehicleBox.getAll();
  }

  @override
  Future<Vehicle> update(int id, Vehicle updatedVehicle) async {
    vehicleBox.put(updatedVehicle, mode: PutMode.update);
    return updatedVehicle;
  }

  @override
  Future<Vehicle?> delete(int id) async {
    Vehicle? vehicle = vehicleBox.get(id);

    if (vehicle != null) {
      vehicleBox.remove(id);
    }

    return vehicle;
  }
}
