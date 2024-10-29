import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:cli_shared/cli_shared.dart';

Future<Response> postParkingHandler(Request request) async {
  try {
    final data = await request.readAsString();
    final json = jsonDecode(data);
    var parking = Parking.fromJson(json);

    parking = await parkingRepository.create(parking);
    return Response.ok(jsonEncode(parking.toJson()),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create parking'}));
  }
}

Future<Response> getParkingsHandler(Request request) async {
  try {
    final parkings = await parkingRepository.getAll();
    return Response.ok(jsonEncode(parkings.map((p) => p.toJson()).toList()));
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to retrieve parkings'}));
  }

// Implement `getParkingHandler`, `updateParkingHandler`, `stopParkingHandler`
}
