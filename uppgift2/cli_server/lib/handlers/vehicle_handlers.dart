import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:cli_shared/cli_shared.dart';
import '../repositories/vehicle_repository.dart';

final vehicleRepository = VehicleRepository();

/// Get all vehicles
Future<Response> getVehiclesHandler(Request request) async {
  try {
    List<Vehicle> vehicles = await vehicleRepository.getAll();
    final jsonResponse = jsonEncode(vehicles.map((v) => v.toJson()).toList());
    return Response.ok(jsonResponse,
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to retrieve vehicles'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

/// Get a specific vehicle by ID
Future<Response> getVehicleHandler(Request request) async {
  final id = int.tryParse(request.params['id'] ?? '');
  if (id == null) {
    return Response(400,
        body: jsonEncode({'error': 'Invalid ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  try {
    final vehicle = await vehicleRepository.getById(id);
    if (vehicle == null) {
      return Response(404,
          body: jsonEncode({'error': 'Vehicle not found'}),
          headers: {'Content-Type': 'application/json'});
    }

    return Response.ok(jsonEncode(vehicle.toJson()),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to retrieve vehicle'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

/// Create a new vehicle
Future<Response> postVehicleHandler(Request request) async {
  try {
    final payload = await request.readAsString();
    final json = jsonDecode(payload);

    Vehicle vehicle = Vehicle.fromJson(json);
    vehicle = await vehicleRepository.create(vehicle);

    return Response(201,
        body: jsonEncode(vehicle.toJson()),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to create vehicle'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

/// Update an existing vehicle by ID
Future<Response> updateVehicleHandler(Request request) async {
  final id = int.tryParse(request.params['id'] ?? '');
  if (id == null) {
    return Response(400,
        body: jsonEncode({'error': 'Invalid ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  try {
    final payload = await request.readAsString();
    final json = jsonDecode(payload);

    Vehicle updatedVehicle = Vehicle.fromJson(json);
    final vehicle = await vehicleRepository.update(id, updatedVehicle);

    if (vehicle == null) {
      return Response(404,
          body: jsonEncode({'error': 'Vehicle not found'}),
          headers: {'Content-Type': 'application/json'});
    }

    return Response.ok(jsonEncode(vehicle.toJson()),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to update vehicle'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

/// Delete a vehicle by ID
Future<Response> deleteVehicleHandler(Request request) async {
  final id = int.tryParse(request.params['id'] ?? '');
  if (id == null) {
    return Response(400,
        body: jsonEncode({'error': 'Invalid ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  try {
    final deletedVehicle = await vehicleRepository.delete(id);
    if (deletedVehicle == null) {
      return Response(404,
          body: jsonEncode({'error': 'Vehicle not found'}),
          headers: {'Content-Type': 'application/json'});
    }

    return Response.ok(jsonEncode({'message': 'Vehicle deleted successfully'}),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to delete vehicle'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

/// Set up routes for vehicle handlers
Router vehicleRoutes() {
  final router = Router();

  router.get('/', getVehiclesHandler);
  router.get('/<id|[0-9]+>', getVehicleHandler);
  router.post('/', postVehicleHandler);
  router.put('/<id|[0-9]+>', updateVehicleHandler);
  router.delete('/<id|[0-9]+>', deleteVehicleHandler);

  return router;
}
