import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared/shared.dart';

class ParkingSpaceRepository implements RepositoryInterface<ParkingSpace> {
  // final db = FirebaseFirestore.instance;
  // final uuid = const Uuid();

  final FirebaseFirestore _db; // Make db a final field
  final Uuid _uuid = const Uuid();

  ParkingSpaceRepository({required FirebaseFirestore db}) : _db = db;

  @override
  Future<ParkingSpace> create(ParkingSpace parkingSpace) async {
    debugPrint("[ParkingSpaceRepository] Creating a new parking space.");

    // Assign a UUID if not already set
    final parkingSpaceId =
        parkingSpace.id.isEmpty ? _uuid.v4() : parkingSpace.id;

    final parkingSpaceToCreate = parkingSpace.copyWith(id: parkingSpaceId);

    await _db
        .collection("parkingSpaces")
        .doc(parkingSpaceId)
        .set(parkingSpaceToCreate.toJson());

    debugPrint(
        "[ParkingSpaceRepository] Parking space created: ${parkingSpaceToCreate.toJson()}");
    return parkingSpaceToCreate;
  }

  @override
  Future<List<ParkingSpace>> getAll() async {
    debugPrint("[ParkingSpaceRepository] Fetching all parking spaces.");

    final snapshots = await _db.collection("parkingSpaces").get();

    final parkingSpaces = snapshots.docs.map((doc) {
      final json = doc.data();
      json["id"] = doc.id;
      return ParkingSpace.fromJson(json);
    }).toList();

    debugPrint(
        "[ParkingSpaceRepository] Fetched parking spaces: $parkingSpaces");
    return parkingSpaces;
  }

  Future<List<ParkingSpace>> getAvailableParkingSpaces() async {
    try {
      final now = DateTime.now();

      // Query for ACTIVE parkings (endTime is after now OR endTime is null)
      final activeParkingsSnapshot = await _db
          .collection('parkings')
          .where('endTime', isNull: true) // Active parkings
          .get();

      final activeParkingsSnapshot2 = await _db
          .collection('parkings')
          .where('endTime', isGreaterThan: now) // Active parkings
          .get();

      final activeParkingSpaceIds = [
        ...activeParkingsSnapshot.docs
            .map((doc) => doc.get('parkingSpace')['id'] as String),
        ...activeParkingsSnapshot2.docs
            .map((doc) => doc.get('parkingSpace')['id'] as String)
      ];

      final allParkingSpacesSnapshot =
          await _db.collection('parkingSpaces').get();

      final availableParkingSpaces = allParkingSpacesSnapshot.docs
          .where((doc) => !activeParkingSpaceIds.contains(doc.id))
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ParkingSpace.fromJson(data);
      }).toList();

      return availableParkingSpaces;
    } catch (e) {
      debugPrint(
          '[ParkingSpaceRepository] Error getting available parking spaces: $e');
      rethrow;
    }
  }

  @override
  Future<ParkingSpace?> getById(String id) async {
    debugPrint("[ParkingSpaceRepository] Fetching parking space with ID: $id");

    final snapshot = await _db.collection("parkingSpaces").doc(id).get();

    final json = snapshot.data();

    if (json == null) {
      debugPrint(
          "[ParkingSpaceRepository] Parking space not found with ID: $id");
      return null;
    }

    json["id"] = snapshot.id;

    final parkingSpace = ParkingSpace.fromJson(json);
    debugPrint("[ParkingSpaceRepository] Parking space fetched: $parkingSpace");
    return parkingSpace;
  }

  @override
  Future<ParkingSpace> update(String id, ParkingSpace parkingSpace) async {
    debugPrint("[ParkingSpaceRepository] Updating parking space with ID: $id");

    await _db.collection("parkingSpaces").doc(id).set(parkingSpace.toJson());

    debugPrint(
        "[ParkingSpaceRepository] Parking space updated: ${parkingSpace.toJson()}");
    return parkingSpace;
  }

Future<void> updateParkingSpaceAvailabilityBatch(
      List<ParkingSpace> parkingSpaces, bool isAvailable) async {
    try {
      final batch = _db.batch();

      for (final space in parkingSpaces) {
        final docRef = _db.collection("parkingSpaces").doc(space.id);
        debugPrint(
            "[ParkingSpaceRepository] Updating parking space availability: $space, isAvailable: $isAvailable");
        batch.update(docRef, {'isAvailable': isAvailable});
      }

      await batch.commit();
      debugPrint(
          "[ParkingSpaceRepository] Batch update of parking space availability completed.");
    } catch (e) {
      debugPrint(
          "[ParkingSpaceRepository] Error in batch update of parking space availability: $e");
      rethrow;
    }
  }

  @override
  Future<ParkingSpace?> delete(String id) async {
    debugPrint("[ParkingSpaceRepository] Deleting parking space with ID: $id");

    final parkingSpace = await getById(id);

    if (parkingSpace != null) {
      await _db.collection("parkingSpaces").doc(id).delete();
      debugPrint(
          "[ParkingSpaceRepository] Parking space deleted: $parkingSpace");
    } else {
      debugPrint(
          "[ParkingSpaceRepository] Parking space not found for deletion.");
    }

    return parkingSpace;
  }

  /// Check if a parking space is occupied
  Future<bool> isOccupied(String parkingSpaceId) async {
    debugPrint(
        "[ParkingSpaceRepository] Checking if parking space is occupied with ID: $parkingSpaceId");

    final snapshots = await _db
        .collection("parkings")
        .where("parkingSpace.id", isEqualTo: parkingSpaceId)
        .where("endTime", isNull: true)
        .get();

    final isOccupied = snapshots.docs.isNotEmpty;

    debugPrint("[ParkingSpaceRepository] Parking space occupied: $isOccupied");
    return isOccupied;
  }

  /// **Stream to Listen for Parking Space Updates**
  Stream<List<ParkingSpace>> parkingSpacesStream() {
    debugPrint(
        "[ParkingSpaceRepository] Listening to parking space updates...");

    return _db.collection("parkingSpaces").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final json = doc.data();
        json["id"] = doc.id;
        return ParkingSpace.fromJson(json);
      }).toList();
    });
  }
}
