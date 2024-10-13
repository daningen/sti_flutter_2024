import 'package:dart_application_1/models/parking_space.dart';
import 'package:dart_application_1/repositories/repository.dart';

class ParkingSpaceRepository extends Repository<ParkingSpace> {
  ParkingSpaceRepository(this._items);

  List<ParkingSpace> get items => _items;

  void addParkingSpace(ParkingSpace parkingSpace) {
    _items.add(parkingSpace);
  }

  final List<ParkingSpace> _items;

  ParkingSpace? getById(String id) {
    return _items.firstWhere((space) => space.id == id);
  }

  List<ParkingSpace> getAllParkingSpaces() {
    return _items;
  }

  ParkingSpace? getParkingSpaceById(String parkingSpaceId) {
    return _items.firstWhere((space) => space.id == parkingSpaceId);
  }

  void deleteParkingSpace(ParkingSpace parkingSpaceToDelete) {
    _items.remove(parkingSpaceToDelete);
  }
}
