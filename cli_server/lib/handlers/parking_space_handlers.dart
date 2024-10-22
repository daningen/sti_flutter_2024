import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:cli_server/globals.dart'; // Ensure you're using the repository from globals.dart
import 'package:cli_server/models/parking_space.dart';
import 'package:shelf_router/shelf_router.dart';

// Handler to get all parking spaces
Future<Response> getAllParkingSpacesHandler(Request req) async {
  print("Handling GET /parking-spaces");

  List<ParkingSpace> allParkingSpaces = await parkingSpaceRepository.getAll();

  print(
      "Parking spaces retrieved: ${allParkingSpaces.map((ps) => ps.toJson()).toList()}");

  if (allParkingSpaces.isEmpty) {
    return Response.ok('[]', headers: {'Content-Type': 'application/json'});
  }

  final jsonResponse =
      jsonEncode(allParkingSpaces.map((ps) => ps.toJson()).toList());
  return Response.ok(jsonResponse,
      headers: {'Content-Type': 'application/json'});
}

// Handler to get a specific parking space by ID
Future<Response> getParkingSpaceHandler(Request request) async {
  print("Handling GET /parking-spaces/<id>");

  final id = int.tryParse(request.params['id']!);
  if (id == null) {
    return Response.notFound(jsonEncode({'error': 'Invalid parking space ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  final parkingSpace = await parkingSpaceRepository.getById(id);
  if (parkingSpace == null) {
    return Response.notFound(jsonEncode({'error': 'Parking space not found'}),
        headers: {'Content-Type': 'application/json'});
  }

  return Response.ok(jsonEncode(parkingSpace.toJson()),
      headers: {'Content-Type': 'application/json'});
}

// Handler to add a new parking space
Future<Response> addParkingSpaceHandler(Request req) async {
  try {
    final payload = await req.readAsString();
    print("Handling POST /parking-spaces - Received payload: $payload");
    final parkingSpaceData = jsonDecode(payload);

    if (parkingSpaceData.containsKey('address') &&
        parkingSpaceData.containsKey('pricePerHour')) {
      // Generate new ID
      final newId = (await parkingSpaceRepository.getAll()).length + 1;

      // Create the parking space object
      final newParkingSpace = ParkingSpace(
        id: newId,
        address: parkingSpaceData['address'],
        pricePerHour: parkingSpaceData['pricePerHour'],
      );

      await parkingSpaceRepository.add(newParkingSpace);

      print(
          "Parking spaces after addition: ${(await parkingSpaceRepository.getAll()).map((ps) => ps.toJson()).toList()}");

      final jsonResponse = jsonEncode({
        'message': 'Parking space added successfully',
        'parkingSpace': newParkingSpace.toJson(),
      });

      return Response(201,
          body: jsonResponse, headers: {'Content-Type': 'application/json'});
    } else {
      return Response(400,
          body: jsonEncode({'error': 'Invalid parking space data'}),
          headers: {'Content-Type': 'application/json'});
    }
  } catch (e) {
    print('Error while adding parking space: $e');
    return Response(500,
        body: jsonEncode({'error': 'Internal Server Error'}),
        headers: {'Content-Type': 'application/json'});
  }
}

// Handler to update an existing parking space by ID
Future<Response> updateParkingSpaceHandler(Request request) async {
  print("Handling PUT /parking-spaces/<id>");

  final id = int.tryParse(request.params['id']!);
  if (id == null) {
    return Response.notFound(jsonEncode({'error': 'Invalid parking space ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  final payload = await request.readAsString();
  final parkingSpaceData = jsonDecode(payload);

  final existingParkingSpace = await parkingSpaceRepository.getById(id);
  if (existingParkingSpace == null) {
    return Response.notFound(jsonEncode({'error': 'Parking space not found'}),
        headers: {'Content-Type': 'application/json'});
  }

  if (parkingSpaceData.containsKey('address') &&
      parkingSpaceData.containsKey('pricePerHour')) {
    final updatedParkingSpace = ParkingSpace(
      id: id,
      address: parkingSpaceData['address'],
      pricePerHour: parkingSpaceData['pricePerHour'],
    );

    await parkingSpaceRepository.update(
        existingParkingSpace, updatedParkingSpace);

    return Response.ok(
        jsonEncode({
          'message': 'Parking space updated successfully',
          'parkingSpace': updatedParkingSpace.toJson(),
        }),
        headers: {'Content-Type': 'application/json'});
  } else {
    return Response(400,
        body: jsonEncode({'error': 'Invalid parking space data'}),
        headers: {'Content-Type': 'application/json'});
  }
}

// Handler to delete a parking space by ID
Future<Response> deleteParkingSpaceHandler(Request request) async {
  print("Handling DELETE /parking-spaces/<id>");

  final id = int.tryParse(request.params['id']!);

  if (id == null) {
    return Response.notFound(jsonEncode({'error': 'Invalid parking space ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  final existingParkingSpace = await parkingSpaceRepository.getById(id);
  if (existingParkingSpace == null) {
    return Response.notFound(jsonEncode({'error': 'Parking space not found'}),
        headers: {'Content-Type': 'application/json'});
  }

  await parkingSpaceRepository.deleteParkingSpace(existingParkingSpace);

  return Response.ok(
      jsonEncode({'message': 'Parking space deleted successfully'}),
      headers: {'Content-Type': 'application/json'});
}
