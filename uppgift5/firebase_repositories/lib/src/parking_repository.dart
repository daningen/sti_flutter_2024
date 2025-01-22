import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart'; // Import the UUID package
import 'package:shared/shared.dart';

class ParkingRepository implements RepositoryInterface<Parking> {
  final db = FirebaseFirestore.instance;
  final uuid = const Uuid(); // Create an instance of Uuid

  @override
  Future<Parking> create(Parking parking) async {
    debugPrint("[ParkingRepository] Creating a new parking session.");

    // Assign a random UUID if not already set
    final parkingId = parking.id.isEmpty ? uuid.v4() : parking.id;

    final parkingToCreate = parking.copyWith(id: parkingId);

    await db
        .collection("parkings")
        .doc(parkingId)
        .set(parkingToCreate.toJson());

    debugPrint(
        "[ParkingRepository] Parking created: ${parkingToCreate.toJson()}");
    return parkingToCreate;
  }

  @override
  Future<List<Parking>> getAll() async {
    debugPrint("[ParkingRepository] Fetching all parking sessions.");

    final snapshots = await db.collection("parkings").get();

    final parkings = snapshots.docs.map((doc) {
      final json = doc.data();
      json["id"] = doc.id;
      return Parking.fromJson(json);
    }).toList();

    debugPrint("[ParkingRepository] Fetched parkings: $parkings");
    return parkings;
  }

  @override
  Future<Parking?> getById(String id) async {
    debugPrint("[ParkingRepository] Fetching parking session with ID: $id");

    final snapshot = await db.collection("parkings").doc(id).get();

    final json = snapshot.data();

    if (json == null) {
      debugPrint("[ParkingRepository] Parking not found with ID: $id");
      return null;
    }

    json["id"] = snapshot.id;

    final parking = Parking.fromJson(json);
    debugPrint("[ParkingRepository] Parking session fetched: $parking");
    return parking;
  }

  @override
  Future<Parking> update(String id, Parking parking) async {
    debugPrint("[ParkingRepository] Updating parking session with ID: $id");

    await db.collection("parkings").doc(id).set(parking.toJson());

    debugPrint("[ParkingRepository] Parking updated: ${parking.toJson()}");
    return parking;
  }

  @override
  Future<Parking?> delete(String id) async {
    debugPrint("[ParkingRepository] Deleting parking session with ID: $id");

    final parking = await getById(id);

    if (parking != null) {
      await db.collection("parkings").doc(id).delete();
      debugPrint("[ParkingRepository] Parking deleted: $parking");
    } else {
      debugPrint("[ParkingRepository] Parking not found for deletion.");
    }

    return parking;
  }

  Future<void> stop(String id) async {
    debugPrint("[ParkingRepository] Stopping parking session with ID: $id");

    final parking = await getById(id);

    if (parking != null) {
      final updatedParking = parking.copyWith(endTime: DateTime.now());
      await update(id, updatedParking);
      debugPrint("[ParkingRepository] Parking session stopped successfully.");
    } else {
      debugPrint("[ParkingRepository] Parking not found for stopping.");
      throw Exception("Parking session not found for ID: $id");
    }
  }
}
