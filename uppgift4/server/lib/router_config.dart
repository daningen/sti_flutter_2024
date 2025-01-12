import 'package:server/handlers/bag_handlers.dart';
import 'package:server/handlers/item_handlers.dart';
import 'package:server/handlers/person_handlers.dart';
import 'package:server/handlers/vehicle_handlers.dart';
import 'package:server/handlers/parking_space_handler.dart';
import 'package:server/handlers/parking_handlers.dart';
import 'package:shared/objectbox.g.dart';

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
    // Configure routes
    router = Router();
    store = openStore();

    // Item routes
    router.post('/items', postItemHandler);
    router.get('/items', getItemsHandler);
    router.get('/items/<id>', getItemHandler);
    router.put('/items/<id>', updateItemHandler);
    router.delete('/items/<id>', deleteItemHandler);

    // Bag routes
    router.post('/bags', postBagHandler);
    router.get('/bags', getBagsHandler);
    router.get('/bags/<id>', getBagHandler);
    router.put('/bags/<id>', updateBagHandler);
    router.delete('/bags/<id>', deleteBagHandler);

    // Person routes
    router.post('/persons', postPersonHandler);
    router.get('/persons', getPersonsHandler);
    router.get('/persons/<id>', getPersonHandler);
    router.put('/persons/<id>', updatePersonHandler);
    router.delete('/persons/<id>', deletePersonHandler);

    // Vehicle routes
    router.post('/vehicles', postVehicleHandler);
    router.get('/vehicles', getVehiclesHandler);
    router.get('/vehicles/<id>', getVehicleHandler);
    router.put('/vehicles/<id>', updateVehicleHandler);
    router.delete('/vehicles/<id>', deleteVehicleHandler);

    // Parking Space routes
    router.post('/parking_spaces', postParkingSpaceHandler);
    router.get('/parking_spaces', getParkingSpacesHandler);
    router.get('/parking_spaces/<id>', getParkingSpaceHandler); //
    router.put('/parking_spaces/<id>', updateParkingSpaceHandler); //
    router.delete('/parking_spaces/<id>', deleteParkingSpaceHandler); //

    // Parking routes
    router.post('/parkings', addParkingHandler);
    router.get('/parkings', getAllParkingsHandler);
    router.get('/parkings/<id>', getParkingByIdHandler);

    router.put('/parkings/<id>', updateParkingHandler);

    router.delete('/parkings/<id>', deleteParkingHandler);
    router.put('/parkings/<id>/stop', stopParkingHandler); //use for stopping
  }
}
