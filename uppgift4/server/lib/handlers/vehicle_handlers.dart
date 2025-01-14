import 'dart:convert';

import 'package:server/repositories/vehicle_repository.dart';
import 'package:shared/shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

VehicleRepository repo = VehicleRepository();

// Create
Future<Response> postVehicleHandler(Request request) async {
  try {
    final data = await request.readAsString();
    print("data is  $data");
    final json = jsonDecode(data);
    print('Payload received in backend[vehicle_handlers]');
    print("json is  $json");
    var vehicle = Vehicle.fromJson(json);
    print("vehicle is  $vehicle");

    vehicle = await repo.create(vehicle);

    // Return 201 Created with the vehicle data in the body
    return Response(
      201, // Status code for resource creation
      body: jsonEncode(vehicle.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    print("Error occurred while creating vehicle: $e");
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to create vehicle'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Get all vehicles
Future<Response> getVehiclesHandler(Request request) async {
  try {
    final vehicles = await repo.getAll();
    final payload = vehicles.map((e) => e.toJson()).toList();

    return Response.ok(
      jsonEncode(payload),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to retrieve vehicles'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Get by ID
Future<Response> getVehicleHandler(Request request) async {
  try {
    final idStr = request.params["id"];
    if (idStr == null) return Response.badRequest(body: 'ID is required');

    final id = int.tryParse(idStr);
    if (id == null) return Response.badRequest(body: 'Invalid ID format');

    final vehicle = await repo.getById(id);
    if (vehicle == null) {
      return Response.notFound(
        jsonEncode({'error': 'Vehicle not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode(vehicle.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to retrieve vehicle'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Update
Future<Response> updateVehicleHandler(Request request) async {
  try {
    final idStr = request.params["id"];
    if (idStr == null) return Response.badRequest(body: 'ID is required');

    final id = int.tryParse(idStr);
    if (id == null) return Response.badRequest(body: 'Invalid ID format');

    final data = await request.readAsString();
    final json = jsonDecode(data);
    var vehicle = Vehicle.fromJson(json);

    vehicle = await repo.update(id, vehicle);
    return Response.ok(
      jsonEncode(vehicle.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to update vehicle'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Delete by ID
Future<Response> deleteVehicleHandler(Request request) async {
  try {
    final idStr = request.params["id"];
    if (idStr == null) return Response.badRequest(body: 'ID is required');

    final id = int.tryParse(idStr);
    if (id == null) return Response.badRequest(body: 'Invalid ID format');

    final vehicle = await repo.delete(id);
    if (vehicle == null) {
      return Response.notFound(
        jsonEncode({'error': 'Vehicle not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode({'message': 'Vehicle deleted', 'vehicle': vehicle.toJson()}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to delete vehicle'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
