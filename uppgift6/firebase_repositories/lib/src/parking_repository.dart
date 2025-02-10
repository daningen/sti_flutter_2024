import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class ParkingRepository implements RepositoryInterface<Parking> {
  final FirebaseFirestore _db;
  final Uuid _uuid = const Uuid();

  ParkingRepository({required FirebaseFirestore db}) : _db = db;

  @override
  Future<Parking> create(Parking parking) async {
    debugPrint("[ParkingRepository] Creating a new parking session.");

    final parkingId = parking.id.isEmpty ? _uuid.v4() : parking.id;
    final parkingToCreate = parking.copyWith(id: parkingId);

    try {
      await _db
          .collection("parkings")
          .doc(parkingId)
          .set(parkingToCreate.toJson());
      debugPrint(
          "[ParkingRepository] Parking created: ${parkingToCreate.toJson()}");
      return parkingToCreate;
    } catch (e) {
      debugPrint("[ParkingRepository] Error creating parking: $e");
      rethrow;
    }
  }

  @override
  Future<List<Parking>> getAll() async {
    debugPrint("[ParkingRepository] Fetching all parking sessions.");

    try {
      final snapshots = await _db.collection("parkings").get();
      return _mapParkingSnapshots(snapshots);
    } catch (e) {
      debugPrint("[ParkingRepository] Error fetching all parkings: $e");
      rethrow;
    }
  }

  Stream<List<Parking>> getParkingsStream() {
    // Correctly defined outside getAll
    debugPrint("[ParkingRepository] Getting parkings stream...");

    return _db.collection('parkings').snapshots().map((snapshot) {
      debugPrint(
          "[ParkingRepository] Received parkings snapshot: ${snapshot.docs.length} documents");
      return _mapParkingSnapshots(snapshot);
    }).handleError((error) {
      debugPrint("[ParkingRepository] Error getting parkings stream: $error");
      return const Stream.empty(); // Or handle the error as needed
    });
  }

  @override
  Future<Parking?> getById(String id) async {
    debugPrint("[ParkingRepository] Fetching parking session with ID: $id");

    try {
      final docRef = _db.collection("parkings").doc(id);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        return null; // Return null directly
      }

      final data = snapshot.data() as Map<String, dynamic>;
      data['id'] = snapshot.id; // Still good to set the ID here

      return Parking.fromJson(data);
    } catch (e) {
      debugPrint("[ParkingRepository] Error fetching parking by ID: $e");
      rethrow;
    }
  }

  @override
  Future<Parking> update(String id, Parking parking) async {
    debugPrint("[ParkingRepository] Updating parking session with ID: $id");
    debugPrint("[ParkingRepository] Parking to update: ${parking.toJson()}");

    try {
      await _db.collection("parkings").doc(id).set(parking.toJson());
      debugPrint("[ParkingRepository] Parking updated: ${parking.toJson()}");
      return parking;
    } catch (e) {
      debugPrint("[ParkingRepository] Error updating parking: $e");
      rethrow;
    }
  }

  @override
  Future<Parking?> delete(String id) async {
    debugPrint("[ParkingRepository] Deleting parking session with ID: $id");

    try {
      final parking = await getById(id);
      if (parking != null) {
        await _db.collection("parkings").doc(id).delete();
        debugPrint("[ParkingRepository] Parking deleted: $parking");
      } else {
        debugPrint("[ParkingRepository] Parking not found for deletion.");
      }
      return parking;
    } catch (e) {
      debugPrint("[ParkingRepository] Error deleting parking: $e");
      rethrow;
    }
  }

  Future<void> stop(String id) async {
    debugPrint("[ParkingRepository] Stopping parking session with ID: $id");

    try {
      final parking = await getById(id);
      if (parking != null) {
        debugPrint("[ParkingRepository] Parking to stop: $parking");
        final updatedParking = parking.copyWith(endTime: DateTime.now());
        debugPrint(
            "[ParkingRepository] Updated parking object: $updatedParking");

        await update(id, updatedParking);
        debugPrint("[ParkingRepository] Parking session stopped successfully.");
      } else {
        debugPrint("[ParkingRepository] Parking not found for stopping.");
        throw Exception("Parking session not found for ID: $id");
      }
    } catch (e) {
      debugPrint("[ParkingRepository] Error stopping parking: $e");
      rethrow;
    }
  }

  List<Parking> _mapParkingSnapshots(QuerySnapshot snapshot) {
    List<Parking> parkings = [];

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data == null) {
        debugPrint("WARNING: Document data is null for document ${doc.id}");
        continue;
      }

      try {
        DateTime? endTime;
        debugPrint(
            "Raw endTime value from Firestore (document ${doc.id}): ${data['endTime']}");

        if (data['endTime'] != null) {
          debugPrint(
              "endTime type (document ${doc.id}): ${data['endTime'].runtimeType}");

          if (data['endTime'] is Timestamp) {
            endTime = (data['endTime'] as Timestamp).toDate();
            debugPrint(
                "Parsed endTime (Timestamp, document ${doc.id}): $endTime");
          } else if (data['endTime'] is DateTime) {
            endTime = data['endTime'] as DateTime;
            debugPrint(
                "Parsed endTime (DateTime, document ${doc.id}): $endTime");
          } else if (data['endTime'] is String) {
            try {
              endTime = DateTime.parse(data['endTime']);
              debugPrint(
                  "Parsed endTime (String, document ${doc.id}): $endTime");
            } catch (e) {
              debugPrint(
                  "Error parsing endTime String (document ${doc.id}): $e");
              endTime = null;
            }
          } else {
            debugPrint(
                "WARNING: endTime is of unexpected type (document ${doc.id}): ${data['endTime'].runtimeType}");
          }
        } else {
          debugPrint(
              "WARNING: endTime is null in Firestore document: ${doc.id}");
        }
        debugPrint("Vehicle Data (Document ${doc.id}): ${data['vehicle']}");
        debugPrint(
            "ParkingSpace Data (Document ${doc.id}): ${data['parkingSpace']}");

        final parking = Parking.fromJson({
          ...data,
          'endTime': endTime,
        });

        debugPrint('Parking from JSON (document ${doc.id}): $parking');

        parkings.add(parking);
        debugPrint(
            "About to add to parkings list endTime: ${parking.endTime} for document ${doc.id}");
      } catch (e) {
        debugPrint(
            'Error deserializing parking (document ${doc.id}): $e, data: $data');
      }
    }
    return parkings;
  }
}
