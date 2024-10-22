import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:cli_server/models/vehicle.dart';
import 'package:cli_server/models/person.dart';
import 'package:cli_server/globals.dart';
import 'package:shelf_router/shelf_router.dart';

// Handler to get all vehicles
Future<Response> getAllVehiclesHandler(Request req) async {
  print("Handling GET /vehicles");

  List<Vehicle> allVehicles = await vehicleRepository.getAll();
  print(
      "Vehicles retrieved from repository: ${allVehicles.map((v) => v.toJson()).toList()}");

  if (allVehicles.isEmpty) {
    return Response.ok('[]', headers: {'Content-Type': 'application/json'});
  }

  final jsonResponse = jsonEncode(allVehicles.map((v) => v.toJson()).toList());
  return Response.ok(jsonResponse,
      headers: {'Content-Type': 'application/json'});
}

// Handler to get a specific vehicle by ID

Future<Response> getVehicleHandler(Request request) async {
  final id = int.tryParse(request.params['id']!); // This will work now

  if (id == null) {
    return Response.notFound(jsonEncode({'error': 'Invalid vehicle ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  final vehicle = await vehicleRepository.getVehicleById(id);
  if (vehicle == null) {
    return Response.notFound(jsonEncode({'error': 'Vehicle not found'}),
        headers: {'Content-Type': 'application/json'});
  }

  return Response.ok(jsonEncode(vehicle.toJson()),
      headers: {'Content-Type': 'application/json'});
}

// Handler to add a new vehicle
Future<Response> addVehicleHandler(Request req) async {
  try {
    final payload = await req.readAsString();
    print(
        "Handling POST /vehicles - Received payload: $payload"); // Log the incoming data
    final vehicleData = jsonDecode(payload);

    if (vehicleData.containsKey('licensePlate') &&
        vehicleData.containsKey('vehicleType') &&
        vehicleData.containsKey('owner') &&
        vehicleData['owner'].containsKey('name') &&
        vehicleData['owner'].containsKey('ssn')) {
      // Generate new ID for the vehicle
      final newId = (await vehicleRepository.getAll()).length + 1;

      // Create the new vehicle object
      final newVehicle = Vehicle(
        id: newId,
        licensePlate: vehicleData['licensePlate'],
        vehicleType: vehicleData['vehicleType'],
        owner: Person(
          id: newId,
          name: vehicleData['owner']['name'],
          ssn: vehicleData['owner']['ssn'],
        ),
      );

      // Add the vehicle to the repository
      await vehicleRepository.add(newVehicle);
      print(
          "Vehicles in repository after addition: ${(await vehicleRepository.getAll()).map((v) => v.toJson()).toList()}");

      final jsonResponse = jsonEncode({
        'message': 'Vehicle added successfully',
        'vehicle': newVehicle.toJson(),
        'totalVehicles': (await vehicleRepository.getAll()).length,
      });

      return Response(201,
          body: jsonResponse, headers: {'Content-Type': 'application/json'});
    } else {
      return Response(400,
          body: jsonEncode({'error': 'Invalid vehicle data'}),
          headers: {'Content-Type': 'application/json'});
    }
  } catch (e, stackTrace) {
    print('Error while adding vehicle: $e');
    print(stackTrace);
    return Response(500,
        body: jsonEncode({'error': 'Internal Server Error'}),
        headers: {'Content-Type': 'application/json'});
  }
}

// Handler to update an existing vehicle by ID
Future<Response> updateVehicleHandler(Request request) async {
  print("Handling PUT /vehicles/<id>");

  final id = int.tryParse(request.params['id']!);

  if (id == null) {
    return Response.notFound(jsonEncode({'error': 'Invalid vehicle ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  final payload = await request.readAsString();
  final vehicleData = jsonDecode(payload);

  final existingVehicle = await vehicleRepository.getVehicleById(id);
  if (existingVehicle == null) {
    return Response.notFound(jsonEncode({'error': 'Vehicle not found'}),
        headers: {'Content-Type': 'application/json'});
  }

  if (vehicleData.containsKey('licensePlate') &&
      vehicleData.containsKey('vehicleType') &&
      vehicleData.containsKey('owner') &&
      vehicleData['owner'].containsKey('name') &&
      vehicleData['owner'].containsKey('ssn')) {
    final updatedVehicle = Vehicle(
      id: id,
      licensePlate: vehicleData['licensePlate'],
      vehicleType: vehicleData['vehicleType'],
      owner: Person(
        id: existingVehicle.owner.id,
        name: vehicleData['owner']['name'],
        ssn: vehicleData['owner']['ssn'],
      ),
    );

    await vehicleRepository.updateVehicle(id, updatedVehicle);

    return Response.ok(
        jsonEncode({
          'message': 'Vehicle updated successfully',
          'vehicle': updatedVehicle.toJson()
        }),
        headers: {'Content-Type': 'application/json'});
  } else {
    return Response(400,
        body: jsonEncode({'error': 'Invalid vehicle data'}),
        headers: {'Content-Type': 'application/json'});
  }
}

// Handler to delete a vehicle by ID
Future<Response> deleteVehicleHandler(Request request) async {
  print("Handling DELETE /vehicles/<id>");

  final id = int.tryParse(request.params['id']!);

  if (id == null) {
    return Response.notFound(jsonEncode({'error': 'Invalid vehicle ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  final existingVehicle = await vehicleRepository.getVehicleById(id);
  if (existingVehicle == null) {
    return Response.notFound(jsonEncode({'error': 'Vehicle not found'}),
        headers: {'Content-Type': 'application/json'});
  }

  await vehicleRepository.deleteVehicleById(id);
  return Response.ok(jsonEncode({'message': 'Vehicle deleted successfully'}),
      headers: {'Content-Type': 'application/json'});
}
