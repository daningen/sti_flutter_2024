import 'dart:io';
import 'package:cli_server/globals.dart';
import 'package:cli_server/handlers/parking_handlers.dart';
import 'package:cli_server/handlers/parking_space_handlers.dart';
import 'package:cli_server/handlers/person_handlers.dart';
import 'package:cli_server/handlers/vehicle_handlers.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Configure the router with routes for vehicles, persons, parking spaces, and parkings
final _router = Router()
  ..get('/vehicles', getAllVehiclesHandler)
  ..get('/vehicles/<id>', getVehicleHandler)
  ..post('/vehicles', addVehicleHandler)
  ..put('/vehicles/<id>', updateVehicleHandler)
  ..delete('/vehicles/<id>', deleteVehicleHandler)
  ..get('/persons', getAllPersonsHandler)
  ..get('/persons/<id>', getPersonHandler)
  ..post('/persons', addPersonHandler)
  ..put('/persons/<id>', updatePersonHandler)
  ..delete('/persons/<id>', deletePersonHandler)
  ..get('/parking-spaces', getAllParkingSpacesHandler)
  ..get('/parking-spaces/<id>', getParkingSpaceHandler)
  ..post('/parking-spaces', addParkingSpaceHandler)
  ..put('/parking-spaces/<id>', updateParkingSpaceHandler)
  ..delete('/parking-spaces/<id>', deleteParkingSpaceHandler)
  ..get('/parkings', getAllParkingsHandler) // Get all parkings
  ..get('/parkings/<id>', getParkingHandler) // Get parking by ID
  ..post('/parkings', addParkingHandler) // Add a new parking
  ..put('/parkings/<id>', updateParkingByIdHandler) // Update parking by ID
  ..delete('/parkings/<id>', deleteParkingHandler); // Delete parking by ID

// Middleware to log incoming requests to the server
Middleware logRequests() {
  return (Handler handler) {
    return (Request request) async {
      print('Received ${request.method} request for ${request.requestedUri}');
      final response = await handler(request);
      return response;
    };
  };
}

void main(List<String> args) async {
  final ip = InternetAddress.anyIPv4; // Bind to any available IP address
  final port = 8080; // Server will run on port 8080
  // Print to ensure globals.dart has been initialized
  printGlobalsStatus();

  // Use middleware to log requests
  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(_router);

  final server = await serve(handler, ip, port);

  print('Server listening on http://${server.address.host}:${server.port}');
}
