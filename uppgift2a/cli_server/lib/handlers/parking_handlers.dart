import 'dart:convert';
import 'package:cli_server/repositories/parking_repository.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:cli_shared/cli_shared.dart'; // Assuming this contains the Parking model

// Mock repository or use actual repository if available
final parkingRepository = ParkingRepository();

// Get all parking sessions
Future<Response> getAllParkingsHandler(Request req) async {
  try {
    List<Parking> allParkings = await parkingRepository.getAll();
    final jsonResponse =
        jsonEncode(allParkings.map((p) => p.toJson()).toList());
    return Response.ok(jsonResponse,
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to retrieve parkings'}),
        headers: {'Content-Type': 'application/json'});
  }
}

// Add a new parking session
Future<Response> addParkingHandler(Request request) async {
  try {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final parking = Parking.fromJson(data);
    await parkingRepository.create(parking);
    return Response.ok(jsonEncode({'message': 'Parking created successfully'}),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create parking'}),
        headers: {'Content-Type': 'application/json'});
  }
}

// Get a specific parking session by ID
Future<Response> getParkingByIdHandler(Request request) async {
  final id = int.tryParse(request.params['id']!);
  if (id == null) {
    return Response.badRequest(body: jsonEncode({'error': 'Invalid ID'}));
  }

  try {
    final parking = await parkingRepository.getById(id);
    if (parking == null) {
      return Response.notFound(jsonEncode({'error': 'Parking not found'}),
          headers: {'Content-Type': 'application/json'});
    }
    return Response.ok(jsonEncode(parking.toJson()),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to retrieve parking'}),
        headers: {'Content-Type': 'application/json'});
  }
}

// Update a parking session by ID
Future<Response> updateParkingHandler(Request request) async {
  final id = int.tryParse(request.params['id']!);
  if (id == null) {
    return Response(400,
        body: jsonEncode({'error': 'Invalid ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  try {
    final parking = await parkingRepository.getById(id);
    if (parking == null) {
      return Response.notFound(jsonEncode({'error': 'Parking not found'}),
          headers: {'Content-Type': 'application/json'});
    }

    // Set end time for stopping the session
    parking.endTime = DateTime.now();
    await parkingRepository.update(id, parking);

    return Response.ok(
      jsonEncode({'message': 'Parking stopped successfully'}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to update parking'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
// Future<Response> updateParkingByIdHandler(Request request) async {
//   final id = int.tryParse(request.params['id']!);
//   if (id == null) {
//     return Response.badRequest(body: jsonEncode({'error': 'Invalid ID'}));
//   }

//   try {
//     final payload = await request.readAsString();
//     final data = jsonDecode(payload);
//     final existingParking = await parkingRepository.getById(id);

//     if (existingParking == null) {
//       return Response.notFound(jsonEncode({'error': 'Parking not found'}),
//           headers: {'Content-Type': 'application/json'});
//     }

//     final updatedParking = Parking.fromJson(data);
//     updatedParking.id = id; // Retain the same ID
//     await parkingRepository.update(id, updatedParking);
//     return Response.ok(jsonEncode({'message': 'Parking updated successfully'}),
//         headers: {'Content-Type': 'application/json'});
//   } catch (e) {
//     return Response.internalServerError(
//         body: jsonEncode({'error': 'Failed to update parking'}),
//         headers: {'Content-Type': 'application/json'});
//   }
// }

// Delete a parking session by ID
Future<Response> deleteParkingHandler(Request request) async {
  final id = int.tryParse(request.params['id']!);
  if (id == null) {
    return Response.badRequest(body: jsonEncode({'error': 'Invalid ID'}));
  }

  try {
    final deletedParking = await parkingRepository.delete(id);
    if (deletedParking == null) {
      return Response.notFound(jsonEncode({'error': 'Parking not found'}),
          headers: {'Content-Type': 'application/json'});
    }
    return Response.ok(jsonEncode({'message': 'Parking deleted successfully'}),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete parking'}),
        headers: {'Content-Type': 'application/json'});
  }
}

// stop parking
Future<Response> stopParkingHandler(Request request) async {
  final id = int.tryParse(request.params['id'] ?? '');
  if (id == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'Invalid ID'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final parking = await parkingRepository.getById(id);
  if (parking == null) {
    return Response.notFound(
      jsonEncode({'error': 'Parking session not found'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  parking.endTime = DateTime.now();
  await parkingRepository.update(id, parking);

  return Response.ok(
    jsonEncode(
        {'message': 'Parking session stopped', 'parking': parking.toJson()}),
    headers: {'Content-Type': 'application/json'},
  );
}
