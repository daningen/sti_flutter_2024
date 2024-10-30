import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:cli_server/repositories/parking_space_repository.dart';
import 'package:cli_shared/cli_shared.dart';

ParkingSpaceRepository repo = ParkingSpaceRepository();

Future<Response> postParkingSpaceHandler(Request request) async {
  try {
    final data = await request.readAsString();
    final json = jsonDecode(data);
    var parkingSpace = ParkingSpace.fromJson(json);

    parkingSpace = await repo.create(parkingSpace);

    return Response.ok(
      jsonEncode(parkingSpace.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    print('Error while creating parking space: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to create parking space'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

Future<Response> getParkingSpacesHandler(Request request) async {
  try {
    final parkingSpaces = await repo.getAll();
    final payload = parkingSpaces.map((e) => e.toJson()).toList();

    return Response.ok(
      jsonEncode(payload),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    print('Error while retrieving parking spaces: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to retrieve parking spaces'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

Future<Response> getParkingSpaceHandler(Request request) async {
  try {
    final idStr = request.params['id'];
    if (idStr == null) return Response.badRequest(body: 'ID is required');

    final id = int.tryParse(idStr);
    if (id == null) return Response.badRequest(body: 'Invalid ID format');

    final parkingSpace = await repo.getById(id);
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
    print('Error while retrieving parking space: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to retrieve parking space'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

Future<Response> updateParkingSpaceHandler(Request request) async {
  try {
    final idStr = request.params['id'];
    if (idStr == null) return Response.badRequest(body: 'ID is required');

    final id = int.tryParse(idStr);
    if (id == null) return Response.badRequest(body: 'Invalid ID format');

    final data = await request.readAsString();
    final json = jsonDecode(data);
    var parkingSpace = ParkingSpace.fromJson(json);

    parkingSpace = await repo.update(id, parkingSpace);
    return Response.ok(
      jsonEncode(parkingSpace.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    print('Error while updating parking space: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to update parking space'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

Future<Response> deleteParkingSpaceHandler(Request request) async {
  try {
    final idStr = request.params['id'];
    if (idStr == null) return Response.badRequest(body: 'ID is required');

    final id = int.tryParse(idStr);
    if (id == null) return Response.badRequest(body: 'Invalid ID format');

    final parkingSpace = await repo.delete(id);
    if (parkingSpace == null) {
      return Response.notFound(
        jsonEncode({'error': 'Parking space not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode({
        'message': 'Parking space deleted',
        'parkingSpace': parkingSpace.toJson()
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    print('Error while deleting parking space: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to delete parking space'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Router configuration for parking space endpoints
Router getParkingSpaceRouter() {
  final router = Router();

  router.post(
      '/parking_spaces', postParkingSpaceHandler); // create a parking space
  router.get(
      '/parking_spaces', getParkingSpacesHandler); // get all parking spaces
  router.get('/parking_spaces/<id>',
      getParkingSpaceHandler); // get specific parking space
  router.put('/parking_spaces/<id>',
      updateParkingSpaceHandler); // update specific parking space
  router.delete('/parking_spaces/<id>',
      deleteParkingSpaceHandler); // delete specific parking space

  return router;
}
