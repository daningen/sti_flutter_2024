// import 'dart:convert';
import 'dart:convert';

import 'package:cli_server/models/parking_space.dart';
import 'package:cli_server/models/person.dart';
import 'package:cli_server/models/vehicle.dart';
import 'package:shelf/shelf.dart';
import 'package:cli_server/globals.dart';
import 'package:cli_server/models/parking.dart';
import 'package:shelf_router/shelf_router.dart';

// Sök alla parkeringar
Future<Response> getAllParkingsHandler(Request req) async {
  print("Handling GET /parkings");

  List<Parking> allParkings = await parkingRepository.getAll();
  print("Parkings retrieved: ${allParkings.map((p) => p.toJson()).toList()}");

  if (allParkings.isEmpty) {
    return Response.ok('[]', headers: {'Content-Type': 'application/json'});
  }

  final jsonResponse = jsonEncode(allParkings.map((p) => p.toJson()).toList());
  return Response.ok(jsonResponse,
      headers: {'Content-Type': 'application/json'});
}

// Sök parkering via ID
Future<Response> getParkingHandler(Request request) async {
  print("Handling GET /parkings/<id>");

  final id = int.tryParse(request.params['id']!);
  if (id == null) {
    return Response.notFound(jsonEncode({'error': 'Invalid parking ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  final parking = await parkingRepository.getById(id);
  if (parking == null) {
    return Response.notFound(jsonEncode({'error': 'Parking not found'}),
        headers: {'Content-Type': 'application/json'});
  }

  return Response.ok(jsonEncode(parking.toJson()),
      headers: {'Content-Type': 'application/json'});
}

// Skapa parkering
Future<Response> addParkingHandler(Request req) async {
  try {
    final payload = await req.readAsString();
    print("Handling POST /parkings - Received payload: $payload");

    final parkingData = jsonDecode(payload);

    if (parkingData.containsKey('vehicle') &&
        parkingData.containsKey('parkingSpace') &&
        parkingData.containsKey('startTime')) {
      final vehicleData = parkingData['vehicle'];
      final parkingSpaceData = parkingData['parkingSpace'];

      // Generera nytt ID till parkering
      final newId = (await parkingRepository.getAll()).length + 1;

      // Skapa Vehicle och ParkingSpace objekt
      final vehicle = Vehicle(
        id: vehicleData['id'],
        licensePlate: vehicleData['licensePlate'],
        vehicleType: vehicleData['vehicleType'],
        owner: Person.fromJson(vehicleData['owner']),
      );

      final parkingSpace = ParkingSpace(
        id: parkingSpaceData['id'],
        address: parkingSpaceData['address'],
        pricePerHour: parkingSpaceData['pricePerHour'],
      );

      // Skapa nytt parkingsobjekt
      final newParking = Parking(
        id: newId,
        vehicle: vehicle,
        parkingSpace: parkingSpace,
        startTime: DateTime.parse(parkingData['startTime']),
        endTime:
            parkingData.containsKey('endTime') && parkingData['endTime'] != null
                ? DateTime.parse(parkingData['endTime'])
                : null,
      );

      // Lägg till parkingssession till repo
      await parkingRepository.add(newParking);

      final jsonResponse = jsonEncode({
        'message': 'Parking added successfully',
        'parking': newParking.toJson(),
      });

      return Response(201,
          body: jsonResponse, headers: {'Content-Type': 'application/json'});
    } else {
      print("Invalid parking data: ${jsonEncode(parkingData)}");
      return Response(400,
          body: jsonEncode({'error': 'Felaktig indata'}),
          headers: {'Content-Type': 'application/json'});
    }
  } catch (e) {
    print('Error while adding parking: $e');
    return Response(500,
        body: jsonEncode({'error': 'Internal Server Error'}),
        headers: {'Content-Type': 'application/json'});
  }
}

//****** */

Future<Response> updateParkingByIdHandler(Request request) async {
  final id = int.tryParse(request.params['id']!);

  if (id == null) {
    return Response(
      400,
      body: jsonEncode({'error': 'Invalid parking ID'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // hämta existerand parkering på ID
  final existingParking = await parkingRepository.getById(id);

  if (existingParking == null) {
    return Response(
      404,
      body: jsonEncode({'error': 'Parking session not found'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Read the request body to get the updated data
  final payload = await request.readAsString();
  final data = jsonDecode(payload);

  // Validera input
  if (data.containsKey('endTime')) {
    // skapa det nya parkeringsobjektet
    final updatedParking = Parking(
      id: existingParking.id,
      vehicle: existingParking.vehicle,
      parkingSpace: ParkingSpace(
        id: existingParking.parkingSpace.id,
        address: data['parkingSpace']['address'] ??
            existingParking.parkingSpace.address,
        pricePerHour: data['parkingSpace']['pricePerHour'] ??
            existingParking.parkingSpace.pricePerHour,
      ),
      startTime: existingParking.startTime,
      endTime: data['endTime'] != null
          ? DateTime.parse(data['endTime'])
          : null, // uppdatera endTime om parkering är stoppad
    );

    // Uppdatera repo
    await parkingRepository.update(existingParking, updatedParking);

    return Response.ok(
      jsonEncode({'message': 'Parking updated successfully'}),
      headers: {'Content-Type': 'application/json'},
    );
  } else {
    // Om endTime saknas
    return Response(
      400,
      body: jsonEncode({'error': 'endTime is missing'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

////******** */

// Stop parkering via registreringsnummer
Future<Response> stopParkingHandler(Request request) async {
  final licensePlate = request.url.queryParameters['licensePlate'];

  if (licensePlate == null || licensePlate.isEmpty) {
    return Response.badRequest(
        body: jsonEncode({'error': 'License plate is required'}),
        headers: {'Content-Type': 'application/json'});
  }

  try {
    await parkingRepository.stopParkingByLicensePlate(licensePlate);
    return Response.ok(
        jsonEncode({'message': 'Parking stopped for $licensePlate'}),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.notFound(
        jsonEncode({
          'error': 'No parking session found for license plate $licensePlate'
        }),
        headers: {'Content-Type': 'application/json'});
  }
}

// Hämta parkering via registreringsnummer
Future<Response> getParkingsByLicensePlateHandler(Request request) async {
  print("Handling GET /parkings?licensePlate=<plate>");

  final licensePlate = request.url.queryParameters['licensePlate'];
  if (licensePlate == null || licensePlate.isEmpty) {
    return Response.badRequest(
        body: jsonEncode({'error': 'License plate is required'}),
        headers: {'Content-Type': 'application/json'});
  }

  List<Parking> matchingParkings = (await parkingRepository.getAll())
      .where((parking) => parking.vehicle.licensePlate == licensePlate)
      .toList();

  if (matchingParkings.isEmpty) {
    return Response.notFound(jsonEncode({'error': 'Ingen parkering hittad'}),
        headers: {'Content-Type': 'application/json'});
  }

  final jsonResponse =
      jsonEncode(matchingParkings.map((p) => p.toJson()).toList());
  return Response.ok(jsonResponse,
      headers: {'Content-Type': 'application/json'});
}

// Ta bort parkering via ID
Future<Response> deleteParkingHandler(Request request) async {
  print("Handling DELETE /parkings/<id>");

  final id = int.tryParse(request.params['id']!);

  if (id == null) {
    return Response.badRequest(
        body: jsonEncode({'error': 'Ogiltigt parkeringsid ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  final existingParking = await parkingRepository.getById(id);
  if (existingParking == null) {
    return Response.notFound(jsonEncode({'error': 'Parkering hittades inte'}),
        headers: {'Content-Type': 'application/json'});
  }

  await parkingRepository.delete(existingParking);

  return Response.ok(jsonEncode({'message': 'Parkering borttagen'}),
      headers: {'Content-Type': 'application/json'});
}
