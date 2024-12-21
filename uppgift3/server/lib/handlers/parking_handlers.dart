import 'dart:convert';

import 'package:server/repositories/parking_repository.dart';
import 'package:shared/shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

final parkingRepository = ParkingRepository();

// Get
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

// Add
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

// Get by ID
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

// // Update by ID , as now I us this for stopping a parking not the best naming
// Future<Response> updateParkingHandler(Request request) async {
//   final id = int.tryParse(request.params['id']!);
//   if (id == null) {
//     return Response(400,
//         body: jsonEncode({'error': 'Invalid ID'}),
//         headers: {'Content-Type': 'application/json'});
//   }

//   try {
//     final parking = await parkingRepository.getById(id);
//     if (parking == null) {
//       return Response.notFound(jsonEncode({'error': 'Parking not found'}),
//           headers: {'Content-Type': 'application/json'});
//     }

//     // Set end time for stopping the session
//     parking.endTime = DateTime.now();
//     await parkingRepository.update(id, parking);
//     print("setting endtime in updateParkingHandler");

//     return Response.ok(
//       jsonEncode({'message': 'Parking stopped successfully'}),
//       headers: {'Content-Type': 'application/json'},
//     );
//   } catch (e) {
//     return Response.internalServerError(
//       body: jsonEncode({'error': 'Failed to update parking'}),
//       headers: {'Content-Type': 'application/json'},
//     );
//   }
// }

//use this when I update the details on a parking
Future<Response> updateParkingHandler(Request request) async {
  final id = int.tryParse(request.params['id']!);
  if (id == null) {
    return Response.badRequest(body: jsonEncode({'error': 'Invalid ID'}));
  }

  try {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final updatedParking = Parking.fromJson(data);

    // Update the parking details in repository (excluding end time)
    await parkingRepository.update(id, updatedParking);

    // Retrieve the updated parking object (optional)
    final updatedParkingFromDb = await parkingRepository.getById(id);

    return Response.ok(
      jsonEncode(updatedParkingFromDb?.toJson() ?? {}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to update parking'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Delete by ID
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
  // Parse the ID from the request
  final id = int.tryParse(request.params['id'] ?? '');
  print("in  stopParkingHandler");
  if (id == null) {
    // Log the invalid ID
    print('Invalid ID received for stopping parking');
    return Response.badRequest(
      body: jsonEncode({'error': 'Invalid ID'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Log the received request with ID
  print('Received request to stop parking with ID: $id');

  // Attempt to retrieve the parking session
  final parking = await parkingRepository.getById(id);
  if (parking == null) {
    // Log if the parking session is not found
    print('Parking session with ID $id not found');
    return Response.notFound(
      jsonEncode({'error': 'Parking session not found'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Set the end time for the parking session
  parking.endTime = DateTime.now();
  print("call parkingRepository.update now to set end time with $parking");
  await parkingRepository.update(id, parking);

  // Log the successful update
  print(
      'Parking session with ID $id successfully stopped at ${parking.endTime}');

  // Return a successful response
  return Response.ok(
    jsonEncode({
      'message': 'Parking session stopped successfully',
      'parking': parking.toJson(),
    }),
    headers: {'Content-Type': 'application/json'},
  );
}
