import 'package:cli/models/parking_space.dart';
import 'package:cli/repositories/repository.dart';

class ParkingSpaceRepository extends Repository<ParkingSpace> {
  ParkingSpaceRepository(this._items);

  @override
  final List<ParkingSpace> _items;

  @override
  List<ParkingSpace> get items => _items;

  // Add a new parking space
  @override
  Future<void> add(ParkingSpace parkingSpace) async {
    _items.add(parkingSpace);
  }

  // Retrieve a parking space by ID, return null if not found
  Future<ParkingSpace?> getById(int id) async {
    try {
      return _items.firstWhere((space) => space.id == id);
    } catch (e) {
      return null; // Return null if the parking space is not found
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
  @override
  Future<void> update(ParkingSpace oldSpace, ParkingSpace newSpace) async {
    int index = _items.indexOf(oldSpace);
    if (index != -1) {
      _items[index] = newSpace;
    }
  }
}
