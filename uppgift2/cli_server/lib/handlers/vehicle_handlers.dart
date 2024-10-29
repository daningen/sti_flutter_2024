import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:cli_shared/cli_shared.dart';

Future<Response> postVehicleHandler(Request request) async {
  try {
    final data = await request.readAsString();
    final json = jsonDecode(data);
    var vehicle = Vehicle.fromJson(json);

    vehicle = await vehicleRepository.create(vehicle);
    return Response.ok(jsonEncode(vehicle.toJson()),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create vehicle'}));
  }
}

Future<Response> getVehiclesHandler(Request request) async {
  try {
    final vehicles = await vehicleRepository.getAll();
    return Response.ok(jsonEncode(vehicles.map((v) => v.toJson()).toList()));
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to retrieve vehicles'}));
  }

// Similar structure for `getVehicleHandler`, `updateVehicleHandler`, `deleteVehicleHandler`
}
