import 'package:cli/models/parking_space.dart';
import 'package:cli/repositories/repository.dart';

class ParkingSpaceRepository extends Repository<ParkingSpace> {
  ParkingSpaceRepository(this._items);

  // Removed @override because 'items' does not exist in the Repository superclass
  final List<ParkingSpace> _items;

  // Getter for the items list
  List<ParkingSpace> get items => _items;

  // Removed @override because 'add' does not exist in the Repository superclass
  Future<void> add(ParkingSpace parkingSpace) async {
    _items.add(parkingSpace);
  }

  // Retrieve a parking space by ID
  Future<ParkingSpace?> getById(int id) async {
    try {
      return _items.firstWhere((space) => space.id == id);
    } catch (e) {
      return null;
    }
  }

  // Retrieve all parking spaces
  Future<List<ParkingSpace>> getAllParkingSpaces() async {
    return _items;
  }

  // Delete a parking space by its object reference
  Future<void> deleteParkingSpace(ParkingSpace parkingSpaceToDelete) async {
    _items.remove(parkingSpaceToDelete);
  }

  // Delete a parking space by its ID
  Future<void> deleteParkingSpaceById(int id) async {
    _items.removeWhere((space) => space.id == id);
  }

  // Update a parking space
  Future<void> update(ParkingSpace oldSpace, ParkingSpace newSpace) async {
    int index = _items.indexOf(oldSpace);
    if (index != -1) {
      _items[index] = newSpace;
    }
  }
}
