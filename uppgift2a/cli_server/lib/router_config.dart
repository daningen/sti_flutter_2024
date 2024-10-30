import 'package:cli_server/handlers/bag_handlers.dart';
import 'package:cli_server/handlers/item_handlers.dart';
import 'package:cli_server/handlers/person_handlers.dart';
import 'package:cli_server/handlers/vehicle_handlers.dart';
import 'package:cli_server/handlers/parking_space_handler.dart';
import 'package:cli_server/handlers/parking_handlers.dart'; // Import parking handlers

import 'package:cli_shared/cli_shared.dart';
import 'package:shelf_router/shelf_router.dart';

class ServerConfig {
  // singleton constructor
  ServerConfig._privateConstructor() {
    initialize();
  }

  static final ServerConfig _instance = ServerConfig._privateConstructor();

  static ServerConfig get instance => _instance;

  late Store store;
  late Router router;

  initialize() {
    // Configure routes.
    router = Router();
    store = openStore();

    // Item routes
    router.post('/items', postItemHandler); // create an item
    router.get('/items', getItemsHandler); // get all items
    router.get('/items/<id>', getItemHandler); // get specific item
    router.put('/items/<id>', updateItemHandler); // update specific item
    router.delete('/items/<id>', deleteItemHandler); // delete specific item

    // Bag routes
    router.post('/bags', postBagHandler); // create a bag
    router.get('/bags', getBagsHandler); // get all bags
    router.get('/bags/<id>', getBagHandler); // get specific bag
    router.put('/bags/<id>', updateBagHandler); // update specific bag
    router.delete('/bags/<id>', deleteBagHandler); // delete specific bag

    // Person routes
    router.post('/persons', postPersonHandler); // create a person
    router.get('/persons', getPersonsHandler); // get all persons
    router.get('/persons/<id>', getPersonHandler); // get specific person
    router.put('/persons/<id>', updatePersonHandler); // update specific person
    router.delete(
        '/persons/<id>', deletePersonHandler); // delete specific person

    // Vehicle routes
    router.post('/vehicles', postVehicleHandler); // create a vehicle
    router.get('/vehicles', getVehiclesHandler); // get all vehicles
    router.get('/vehicles/<id>', getVehicleHandler); // get specific vehicle
    router.put(
        '/vehicles/<id>', updateVehicleHandler); // update specific vehicle
    router.delete(
        '/vehicles/<id>', deleteVehicleHandler); // delete specific vehicle

    // Parking Space routes
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

    // Parking routes
    router.post('/parkings', addParkingHandler); // create a parking session
    router.get('/parkings', getAllParkingsHandler); // get all parking sessions
    router.get('/parkings/<id>',
        getParkingByIdHandler); // get specific parking session

    router.put('/parkings/<id>', updateParkingHandler);
    router.delete(
        '/parkings/<id>', deleteParkingHandler); // delete a parking session
    router.put('/parkings/<id>',
        stopParkingHandler); // stop specific parking session by setting end time
  }
}
