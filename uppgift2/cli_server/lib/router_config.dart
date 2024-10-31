import 'package:cli_server/handlers/bag_handlers.dart';
import 'package:cli_server/handlers/item_handlers.dart';
import 'package:cli_server/handlers/parking_handlers.dart';
import 'package:cli_server/handlers/parking_space_handlers.dart';
import 'package:cli_server/handlers/person_handlers.dart';
import 'package:cli_server/handlers/vehicle_handlers.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:shelf_router/shelf_router.dart';

class ServerConfig {
  // Singleton constructor
  ServerConfig._privateConstructor() {
    initialize();
  }

  static final ServerConfig _instance = ServerConfig._privateConstructor();

  static ServerConfig get instance => _instance;

  late Store store;
  late Router router;

  void initialize() {
    // Configure routes
    router = Router();
    store = openStore();

    // Item routes
    router.post('/items', postItemHandler); // Create item
    router.get('/items', getItemsHandler); // Get all items
    router.get('/items/<id>', getItemHandler); // Get specific item
    router.put('/items/<id>', updateItemHandler); // Update item
    router.delete('/items/<id>', deleteItemHandler); // Delete item

    // Bag routes
    router.post('/bags', postBagHandler); // Create bag
    router.get('/bags', getBagsHandler); // Get all bags
    router.get('/bags/<id>', getBagHandler); // Get specific bag
    router.put('/bags/<id>', updateBagHandler); // Update bag
    router.delete('/bags/<id>', deleteBagHandler); // Delete bag

    // Person routes
    router.post('/persons', postPersonHandler); // Create person
    router.get('/persons', getPersonsHandler); // Get all persons
    router.get('/persons/<id>', getPersonHandler); // Get specific person
    router.put('/persons/<id>', updatePersonHandler); // Update person
    router.delete('/persons/<id>', deletePersonHandler); // Delete person

    // Vehicle routes
    router.post('/vehicles', postVehicleHandler); // Create vehicle
    router.get('/vehicles', getVehiclesHandler); // Get all vehicles
    router.get('/vehicles/<id>', getVehicleHandler); // Get specific vehicle
    router.put('/vehicles/<id>', updateVehicleHandler); // Update vehicle
    router.delete('/vehicles/<id>', deleteVehicleHandler); // Delete vehicle

    // Parking Space routes
    router.post(
        '/parking_spaces', postParkingSpaceHandler); // Create parking space
    router.get(
        '/parking_spaces', getParkingSpacesHandler); // Get all parking spaces
    router.get('/parking_spaces/<id>',
        getParkingSpaceHandler); // Get specific parking space
    router.put('/parking_spaces/<id>',
        updateParkingSpaceHandler); // Update parking space
    router.delete('/parking_spaces/<id>',
        deleteParkingSpaceHandler); // Delete parking space

    // Parking routes

    router.post('/parkings', postParkingHandler);
    router.get('/parkings', getAllParkingsHandler);
    router.get('/parkings/<id>', getParkingByIdHandler);
    router.put('/parkings/<id>', updateParkingByIdHandler);
  }
}
