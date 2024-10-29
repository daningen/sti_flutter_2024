import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:cli_shared/cli_shared.dart';

Future<Response> postParkingSpaceHandler(Request request) async {
  try {
    final data = await request.readAsString();
    final json = jsonDecode(data);
    var parkingSpace = ParkingSpace.fromJson(json);

    parkingSpace = await parkingSpaceRepository.create(parkingSpace);
    return Response.ok(jsonEncode(parkingSpace.toJson()),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create parking space'}));
  }
}

Future<Response> getParkingSpacesHandler(Request request) async {
  try {
    final spaces = await parkingSpaceRepository.getAll();
    return Response.ok(jsonEncode(spaces.map((s) => s.toJson()).toList()));
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to retrieve parking spaces'}));
  }

// Add additional handlers for `getParkingSpaceHandler`, `updateParkingSpaceHandler`, `deleteParkingSpaceHandler`
}
