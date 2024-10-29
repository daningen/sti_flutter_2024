import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:shelf_router/shelf_router.dart';
import '../repositories/parking_repository.dart';

final parkingRepository = ParkingRepository();

// Handler to get all parkings
Future<Response> getAllParkingsHandler(Request request) async {
  try {
    List<Parking> allParkings = await parkingRepository.getAll();
    final jsonResponse =
        jsonEncode(allParkings.map((p) => p.toJson()).toList());
    return Response.ok(
      jsonResponse,
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to fetch parkings'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Handler to add a new parking session
Future<Response> addParkingHandler(Request request) async {
  try {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final parking = Parking.fromJson(data);

    await parkingRepository.create(parking);

    return Response.ok(
      jsonEncode({'message': 'Parking created successfully'}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to create parking'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Handler to get a specific parking by ID
Future<Response> getParkingByIdHandler(Request request) async {
  final id = int.tryParse(request.params['id'] ?? '');
  if (id == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'Invalid ID format'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  try {
    final parking = await parkingRepository.getById(id);
    if (parking == null) {
      return Response.notFound(
        jsonEncode({'error': 'Parking not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
    return Response.ok(
      jsonEncode(parking.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to fetch parking'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Handler to update a parking session by ID
Future<Response> updateParkingHandler(Request request) async {
  final id = int.tryParse(request.params['id'] ?? '');
  if (id == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'Invalid ID format'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  try {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final existingParking = await parkingRepository.getById(id);

    if (existingParking == null) {
      return Response.notFound(
        jsonEncode({'error': 'Parking not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    existingParking.endTime =
        data['endTime'] != null ? DateTime.parse(data['endTime']) : null;

    await parkingRepository.update(id, existingParking);

    return Response.ok(
      jsonEncode({'message': 'Parking updated successfully'}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to update parking'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Handler to stop a parking session by setting the end time
Future<Response> stopParkingHandler(Request request) async {
  final id = int.tryParse(request.params['id'] ?? '');
  if (id == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'Invalid ID format'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  try {
    final parking = await parkingRepository.getById(id);
    if (parking == null) {
      return Response.notFound(
        jsonEncode({'error': 'Parking not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    parking.endParkingSession();
    await parkingRepository.update(id, parking);

    return Response.ok(
      jsonEncode({'message': 'Parking session stopped'}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to stop parking session'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
