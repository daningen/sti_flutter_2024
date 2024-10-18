import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// A temporary in-memory store for vehicles
final _vehicles = <String, dynamic>{};

// Configure the router with routes for the vehicle operations
final _router = Router()
  ..get('/vehicles', _getAllVehiclesHandler)
  ..get('/vehicles/<licensePlate>', _getVehicleHandler)
  ..post('/vehicles', _addVehicleHandler)
  ..put('/vehicles/<licensePlate>', _updateVehicleHandler)
  ..delete('/vehicles/<licensePlate>', _deleteVehicleHandler);

// Handler to get all vehicles
Response _getAllVehiclesHandler(Request req) {
  final jsonResponse = jsonEncode(_vehicles.values.toList());
  return Response.ok(jsonResponse,
      headers: {'Content-Type': 'application/json'});
}

// Handler to get a specific vehicle by license plate
Response _getVehicleHandler(Request request) {
  final licensePlate = request.params['licensePlate'];

  if (licensePlate == null || !_vehicles.containsKey(licensePlate)) {
    return Response.notFound('Vehicle not found');
  }

  return Response.ok(jsonEncode(_vehicles[licensePlate]),
      headers: {'Content-Type': 'application/json'});
}

Future<Response> _addVehicleHandler(Request req) async {
  final payload = await req.readAsString();
  final vehicle = jsonDecode(payload);

  if (vehicle.containsKey('licensePlate')) {
    _vehicles[vehicle['licensePlate']] = vehicle;

    // Create a response message with details and total vehicles
    final jsonResponse = jsonEncode({
      'message': 'Vehicle added successfully',
      'vehicle': vehicle,
      'totalVehicles': _vehicles.length, // Add total vehicles to response
    });

    return Response(
      201,
      body: jsonResponse,
      headers: {'Content-Type': 'application/json'},
    );
  } else {
    return Response(
      400,
      body: jsonEncode({'error': 'Invalid vehicle data'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Handler to update an existing vehicle
Future<Response> _updateVehicleHandler(Request request) async {
  final licensePlate = request.params['licensePlate'];

  if (licensePlate == null) {
    return Response.notFound('Vehicle not found');
  }

  final payload = await request.readAsString();
  final vehicle = jsonDecode(payload);

  if (_vehicles.containsKey(licensePlate)) {
    _vehicles[licensePlate] = vehicle;
    return Response.ok('Vehicle uppdaterat');
  } else {
    return Response.notFound('Vehicle not found');
  }
}

// Handler to delete a vehicle by license plate
Response _deleteVehicleHandler(Request request) {
  final licensePlate = request.params['licensePlate'];

  if (licensePlate == null || !_vehicles.containsKey(licensePlate)) {
    return Response.notFound('Vehicle not found');
  }

  _vehicles.remove(licensePlate);
  return Response(204);
}

void main(List<String> args) async {
  final ip = InternetAddress.anyIPv4; // Bind to any available IP address
  final port = 8080; // Server will run on port 8080

  final server = await serve(_router.call, ip, port);
  print('Server listening on port $port');
}
