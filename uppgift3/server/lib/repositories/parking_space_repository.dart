import 'package:shared/objectbox.g.dart';
import 'package:shared/shared.dart';

import '../router_config.dart';

class ParkingSpaceRepository implements RepositoryInterface<ParkingSpace> {
  // ObjectBox store to manage ParkingSpace entities.
  final Box<ParkingSpace> _box =
      ServerConfig.instance.store.box<ParkingSpace>();

  @override
  Future<ParkingSpace> create(ParkingSpace parkingSpace) async {
    _box.put(parkingSpace, mode: PutMode.insert);
    return parkingSpace;
  }

  @override
  Future<ParkingSpace?> getById(int id) async {
    return _box.get(id);
  }

  @override
  Future<List<ParkingSpace>> getAll() async {
    return _box.getAll();
  }

  @override
  Future<ParkingSpace> update(int id, ParkingSpace updatedParkingSpace) async {
    updatedParkingSpace.id = id; // Ensure the ID remains consistent.
    _box.put(updatedParkingSpace, mode: PutMode.update);
    return updatedParkingSpace;
  }

  @override
  Future<ParkingSpace?> delete(int id) async {
    final parkingSpace = _box.get(id);
    if (parkingSpace != null) {
      _box.remove(id);
    }
    return parkingSpace;
  }
}
