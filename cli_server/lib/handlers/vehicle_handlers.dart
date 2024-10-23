import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:cli_server/models/vehicle.dart';
import 'package:cli_server/models/person.dart';
import 'package:cli_server/globals.dart';
import 'package:shelf_router/shelf_router.dart';

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

Future<Response> getVehicleHandler(Request request) async {
  final id = int.tryParse(request.params['id']!);

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

Future<Response> addVehicleHandler(Request req) async {
  try {
    final payload = await req.readAsString();
    print("Handling POST /vehicles - Received payload: $payload");
    final vehicleData = jsonDecode(payload);

    // Generate vehicle ID
    final newId = (await vehicleRepository.getAll()).length + 1;

    // Create vehicle object
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

    // Add vehicle to repository
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
  } catch (e) {
    print('Error while adding vehicle: $e');
    return Response(500,
        body: jsonEncode({'error': 'An error occurred while adding vehicle'}),
        headers: {'Content-Type': 'application/json'});
  }
}

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
}

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
