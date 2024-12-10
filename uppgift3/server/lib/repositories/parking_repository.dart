import 'package:shared/objectbox.g.dart';
import 'package:shared/shared.dart';

import '../router_config.dart';

class ParkingRepository implements RepositoryInterface<Parking> {
  // ObjectBox store to manage Parking entities.
  final Box<Parking> _box = ServerConfig.instance.store.box<Parking>();

  @override
  Future<Parking> create(Parking parking) async {
    _box.put(parking, mode: PutMode.insert);
    return parking;
  }

  @override
  Future<Parking?> getById(int id) async {
    return _box.get(id);
  }

  @override
  Future<List<Parking>> getAll() async {
    return _box.getAll();
  }

  @override
  Future<Parking> update(int id, Parking updatedParking) async {
    updatedParking.id = id; // Ensure the ID remains consistent.
    _box.put(updatedParking, mode: PutMode.update);
    return updatedParking;
  }

  @override
  Future<Parking?> delete(int id) async {
    final parking = _box.get(id);
    if (parking != null) {
      _box.remove(id);
    }
    return parking;
  }

  // Additional helper methods (optional)

  // Add or update a parking session
  Future<void> addOrUpdate(Parking parking) async {
    _box.put(parking); // Automatically updates or inserts based on ID
  }

  // Delete a parking session by ID
  Future<void> deleteById(int id) async {
    _box.remove(id);
  }
}
// import 'package:shared/shared.dart';

// class ParkingRepository implements RepositoryInterface<Parking> {
//   final List<Parking> _parkingList =
//       []; // This simulates the in-memory storage.

//   @override
//   Future<Parking?> create(Parking parking) async {
//     _parkingList.add(parking);
//     // If needed, persist the updated list here
//     return parking;
//   }

//   @override
//   Future<Parking?> getById(int id) async {
//     try {
//       return _parkingList.firstWhere((parking) => parking.id == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   @override
//   Future<List<Parking>> getAll() async {
//     // Return a copy of the parking list to simulate fetching from storage.
//     return List<Parking>.from(_parkingList);
//   }

//   @override
//   Future<Parking?> update(int id, Parking updatedParking) async {
//     int index = _parkingList.indexWhere((p) => p.id == id);
//     if (index != -1) {
//       _parkingList[index] = updatedParking;
//       // If needed, persist the updated list here.
//       return updatedParking;
//     }
//     return null;
//   }

//   @override
//   Future<Parking?> delete(int id) async {
//     Parking? parkingToRemove = await getById(id);
//     if (parkingToRemove != null) {
//       _parkingList.removeWhere((p) => p.id == id);
//       // If needed, persist the updated list here.
//     }
//     return parkingToRemove;
//   }

//   // Add or update a parking session (helper method, not part of the interface)
//   Future<void> addOrUpdate(Parking parking) async {
//     int index = _parkingList.indexWhere((p) => p.id == parking.id);
//     if (index != -1) {
//       _parkingList[index] = parking;
//     } else {
//       _parkingList.add(parking);
//     }
//     // Persist the updated list if necessary
//   }

//   // Delete a parking session by ID (helper method, not part of the interface)
//   Future<void> deleteById(int id) async {
//     _parkingList.removeWhere((p) => p.id == id);
//     // Persist the updated list if necessary
//   }
// }
