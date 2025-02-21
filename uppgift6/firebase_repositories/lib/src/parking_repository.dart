import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore interaction
import 'package:shared/shared.dart'; // For shared models (Parking)
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:uuid/uuid.dart'; // For generating unique IDs

class ParkingRepository implements RepositoryInterface<Parking> {
  final FirebaseFirestore _db; // Firestore instance
  final Uuid _uuid = const Uuid(); // UUID generator

  ParkingRepository({required FirebaseFirestore db}) : _db = db;

  /// Creates a new parking session.
  @override
  Future<Parking> create(Parking parking) async {
    debugPrint(
        '[ParkingRepository] Creating a new parking session: ${parking.toJson()}');

    final parkingId = parking.id.isEmpty
        ? _uuid.v4()
        : parking.id; // Generate ID if not provided
    final parkingToCreate =
        parking.copyWith(id: parkingId); // Create a copy with the ID

    try {
      await _db
          .collection("parkings")
          .doc(parkingId)
          .set(parkingToCreate.toJson()); // Store in Firestore
      debugPrint(
          "[ParkingRepository] Parking created: ${parkingToCreate.toJson()}");
      return parkingToCreate;
    } catch (e) {
      debugPrint("[ParkingRepository] Error creating parking: $e");
      rethrow; // Re-throw the error for handling elsewhere
    }
  }

  /// Gets all parking sessions (for admin users).
  @override
  Future<List<Parking>> getAll() async {
    debugPrint("[ParkingRepository] Fetching all parking sessions.");

    try {
      final snapshots =
          await _db.collection("parkings").get(); // Get all documents
      return _mapParkingSnapshots(
          snapshots); // Map snapshots to Parking objects
    } catch (e) {
      debugPrint("[ParkingRepository] Error fetching all parkings: $e");
      rethrow;
    }
  }

  /// Streams parking sessions based on user role and ID.
  Stream<List<Parking>> getParkingsStream(
      String userRole, String loggedInUserAuthId) {
    debugPrint(
        "[ParkingRepository] Getting parkings stream for role: $userRole, user: $loggedInUserAuthId");

    CollectionReference parkingsCollection = _db.collection('parkings');
    Query query;

    if (userRole == 'admin') {
      debugPrint("[ParkingRepository] Querying all parkings (admin)");
      query = parkingsCollection;
    } else {
      debugPrint(
          "[ParkingRepository] Querying parkings for user: $loggedInUserAuthId");
      // query = parkingsCollection.where('ownerAuthId',
      //     isEqualTo: loggedInUserAuthId);
      // query = parkingsCollection.where('vehicle.owner.authId',
      //     isEqualTo: loggedInUserAuthId);
      query = parkingsCollection.where('vehicle.ownerAuthId',
          isEqualTo: loggedInUserAuthId);
    }

    return query.snapshots().map((snapshot) {
      debugPrint(
          "[ParkingRepository] Received ${snapshot.docs.length} parkings");

      final parkings = _mapParkingSnapshots(snapshot);

      debugPrint("[ParkingRepository] Mapped parkings: ${parkings.length}");

      return parkings;
    }).handleError((error) {
      debugPrint("[ParkingRepository] Error getting parkings stream: $error");
      return Stream.value(
          []); // Return an empty list instead of an empty stream
    });
  }

  /// Gets a parking session by ID.
  @override
  Future<Parking?> getById(String id) async {
    debugPrint("[ParkingRepository] Fetching parking session with ID: $id");

    try {
      final docRef =
          _db.collection("parkings").doc(id); // Get document reference
      final snapshot = await docRef.get(); // Get document snapshot

      if (!snapshot.exists) {
        return null; // Return null if document doesn't exist
      }

      final data = snapshot.data() as Map<String, dynamic>; // Get data
      data['id'] = snapshot.id; // Add document ID to data
      return Parking.fromJson(data); // Create Parking object from data
    } catch (e) {
      debugPrint("[ParkingRepository] Error fetching parking by ID: $e");
      rethrow;
    }
  }

  /// Updates a parking session.
  @override
  Future<Parking> update(String id, Parking parking) async {
    debugPrint("[ParkingRepository] Updating parking session with ID: $id");
    debugPrint("[ParkingRepository] Parking to update: ${parking.toJson()}");

    try {
      await _db
          .collection("parkings")
          .doc(id)
          .set(parking.toJson()); // Update in Firestore
      debugPrint("[ParkingRepository] Parking updated: ${parking.toJson()}");
      return parking;
    } catch (e) {
      debugPrint("[ParkingRepository] Error updating parking: $e");
      rethrow;
    }
  }

  /// Deletes a parking session.
  @override
  Future<Parking?> delete(String id) async {
    debugPrint("[ParkingRepository] Deleting parking session with ID: $id");

    try {
      final parking = await getById(id); // Get parking before deleting
      if (parking != null) {
        await _db
            .collection("parkings")
            .doc(id)
            .delete(); // Delete from Firestore
        debugPrint("[ParkingRepository] Parking deleted: $parking");
      } else {
        debugPrint("[ParkingRepository] Parking not found for deletion.");
      }
      return parking; // Return the deleted parking (or null if not found)
    } catch (e) {
      debugPrint("[ParkingRepository] Error deleting parking: $e");
      rethrow;
    }
  }

  /// Stops a parking session (updates the endTime).
  Future<void> stop(String id) async {
    debugPrint("[ParkingRepository] Stopping parking session with ID: $id");

    try {
      final parking = await getById(id); // Get parking before stopping
      if (parking != null) {
        debugPrint("[ParkingRepository] Parking to stop: $parking");
        final updatedParking = parking.copyWith(
            endTime: DateTime.now()); // Create updated parking object
        debugPrint(
            "[ParkingRepository] Updated parking object: $updatedParking");

        await update(id, updatedParking); // Update in Firestore
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

  /// Maps Firestore QuerySnapshot to a list of Parking objects.
  List<Parking> _mapParkingSnapshots(QuerySnapshot snapshot) {
    List<Parking> parkings = [];

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data == null) {
        debugPrint("WARNING: Document data is null for document ${doc.id}");
        continue; // Skip this document if data is null
      }

      try {
        DateTime? endTime;

        debugPrint(
            "[parking_repository:] Raw endTime value from Firestore (document ${doc.id}): ${data['endTime']}");

        // Handle different endTime types (DateTime, String, or null)
        if (data['endTime'] != null) {
          debugPrint(
              "endTime type (document ${doc.id}): ${data['endTime'].runtimeType}");

          if (data['endTime'] is Timestamp) {
            // Correctly handle Firestore Timestamp
            endTime = (data['endTime'] as Timestamp).toDate();
            debugPrint(
                "Parsed endTime (Timestamp, document ${doc.id}): $endTime");
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
          'id': doc.id, // Include the document ID explicitly
        });

        debugPrint('Parking from JSON (document ${doc.id}): $parking');

        parkings.add(parking);
        debugPrint(
            "Added to parkings list endTime: ${parking.endTime} for document ${doc.id}");
      } catch (e) {
        debugPrint(
            'Error deserializing parking (document ${doc.id}): $e, data: $data');
      }
    }
    return parkings;
  }
}
