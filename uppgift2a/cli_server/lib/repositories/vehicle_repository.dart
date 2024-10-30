import 'package:cli_server/router_config.dart';
import 'package:cli_shared/cli_shared.dart';

class VehicleRepository implements RepositoryInterface<Vehicle> {
  // Access the ObjectBox store for Vehicle entities
  Box<Vehicle> vehicleBox = ServerConfig.instance.store.box<Vehicle>();

  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    // Insert the vehicle into the ObjectBox database
    vehicleBox.put(vehicle, mode: PutMode.insert);

    // Return the inserted vehicle object
    return vehicle;
  }

  @override
  Future<Vehicle?> getById(int id) async {
    // Fetch a vehicle by its ID from the ObjectBox database
    return vehicleBox.get(id);
  }

  @override
  Future<List<Vehicle>> getAll() async {
    // Retrieve all vehicles from the ObjectBox database
    print("getAll now for vehicles");
    return vehicleBox.getAll();
  }

  @override
  Future<Vehicle> update(int id, Vehicle updatedVehicle) async {
    // Update the vehicle in the ObjectBox database
    vehicleBox.put(updatedVehicle, mode: PutMode.update);
    return updatedVehicle;
  }

  @override
  Future<Vehicle?> delete(int id) async {
    // Fetch the vehicle to be deleted from the database
    Vehicle? vehicle = vehicleBox.get(id);

    // If the vehicle exists, remove it
    if (vehicle != null) {
      vehicleBox.remove(id);
    }

    // Return the deleted vehicle object or null if not found
    return vehicle;
  }
}
