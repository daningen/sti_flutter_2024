import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:shelf_router/shelf_router.dart';
import '../repositories/parking_space_repository.dart';

final parkingSpaceRepository = ParkingSpaceRepository();

// Handler to create a new parking space
Future<Response> postParkingSpaceHandler(Request request) async {
  try {
    final data = await request.readAsString();
    final json = jsonDecode(data);
    final parkingSpace = ParkingSpace.fromJson(json);

    await parkingSpaceRepository.create(parkingSpace);

    return Response.ok(
      jsonEncode({'message': 'Parking space created successfully'}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to create parking space'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Handler to get all parking spaces
Future<Response> getParkingSpacesHandler(Request request) async {
  try {
    List<ParkingSpace> allParkingSpaces = await parkingSpaceRepository.getAll();
    final jsonResponse =
        jsonEncode(allParkingSpaces.map((p) => p.toJson()).toList());

    return Response.ok(
      jsonResponse,
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to retrieve parking spaces'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Handler to get a specific parking space by ID
Future<Response> getParkingSpaceHandler(Request request) async {
  final id = int.tryParse(request.params['id'] ?? '');
  if (id == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'Invalid ID format'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  try {
    final parkingSpace = await parkingSpaceRepository.getById(id);
    if (parkingSpace == null) {
      return Response.notFound(
        jsonEncode({'error': 'Parking space not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode(parkingSpace.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to retrieve parking space'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Handler to update a parking space by ID
Future<Response> updateParkingSpaceHandler(Request request) async {
  final id = int.tryParse(request.params['id'] ?? '');
  if (id == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'Invalid ID format'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  try {
    final data = await request.readAsString();
    final json = jsonDecode(data);
    final updatedParkingSpace = ParkingSpace.fromJson(json);

    final result = await parkingSpaceRepository.update(id, updatedParkingSpace);
    if (result == null) {
      return Response.notFound(
        jsonEncode({'error': 'Parking space not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode({'message': 'Parking space updated successfully'}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to update parking space'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Handler to delete a parking space by ID
Future<Response> deleteParkingSpaceHandler(Request request) async {
  try {
    final idStr = request.params['id'];
    if (idStr == null) return Response.badRequest(body: 'ID is required');

    final id = int.tryParse(idStr);
    if (id == null) return Response.badRequest(body: 'Invalid ID format');

    // Use parkingSpaceRepo to delete the parking space by ID.
    await parkingSpaceRepository.delete(id);

    return Response.ok(
      jsonEncode({'message': 'Parking space deleted successfully'}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to delete parking space'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
