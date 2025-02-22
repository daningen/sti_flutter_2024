import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:shared/shared.dart'; // For shared models (Vehicle)
import 'package:uuid/uuid.dart'; // For UUID generation

class VehicleRepository implements RepositoryInterface<Vehicle> {
  final FirebaseFirestore _db; // Firestore instance (using _db convention)
  final Uuid _uuid = const Uuid(); // UUID generator

  /// Constructor to inject the Firestore instance.  This is VERY important.
  VehicleRepository({required FirebaseFirestore db}) : _db = db;

  @override
  Future<List<Vehicle>> getAll() async {
    debugPrint("[VehicleRepository] Fetching all vehicles");

    try {
      final snapshot = await _db.collection("vehicles").get();
      final vehicles = snapshot.docs.map((doc) {
        final data = doc.data();
        return Vehicle.fromJson({
          ...data,
          'id': doc.id, // Include the document ID
        });
      }).toList();

      debugPrint("[VehicleRepository] All vehicles fetched: $vehicles");
      return vehicles;
    } catch (e) {
      debugPrint("[VehicleRepository] Error fetching all vehicles: $e");
      rethrow;
    }
  }

  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    debugPrint(
        "[VehicleRepository] Creating a new vehicle: ${vehicle.toJson()}");

    final vehicleId = vehicle.id.isEmpty ? _uuid.v4() : vehicle.id;
    final vehicleToCreate = vehicle.copyWith(id: vehicleId);

    try {
      await _db
          .collection("vehicles")
          .doc(vehicleId)
          .set(vehicleToCreate.toJson());
      debugPrint(
          "[VehicleRepository] Vehicle created: ${vehicleToCreate.toJson()}");
      return vehicleToCreate;
    } catch (e) {
      debugPrint("[VehicleRepository] Error creating vehicle: $e");
      rethrow;
    }
  }

  @override
  Future<Vehicle?> getById(String id) async {
    debugPrint("[VehicleRepository] Fetching vehicle with ID: $id");

    try {
      final snapshot = await _db.collection("vehicles").doc(id).get();
      final json = snapshot.data();

      if (json == null) {
        debugPrint("[VehicleRepository] Vehicle not found with ID: $id");
        return null;
      }

      json["id"] = snapshot.id;

      final vehicle = Vehicle.fromJson(json);
      debugPrint("[VehicleRepository] Vehicle fetched: $vehicle");
      return vehicle;
    } catch (e) {
      debugPrint("[VehicleRepository] Error fetching vehicle by ID: $e");
      rethrow;
    }
  }

  /// Streams available vehicles based on user role and ID.
  ///
  /// This method retrieves a stream of `Vehicle` objects from Firestore.
  /// It filters the vehicles based on the user's role:
  /// - Admin: Retrieves all vehicles.
  /// - Other roles: Retrieves vehicles owned by the logged-in user.
  ///
  ///
  ///
  /// ///
  Future<List<Vehicle>> getAvailableVehiclesStream(
      String userRole, String loggedInUserAuthId) async {
    // Add parameters
    debugPrint(
        "[VehicleRepository] Fetching vehicles for role: $userRole, user: $loggedInUserAuthId");

    try {
      Query query =
          _db.collection("vehicles"); // Start with the base collection

      if (userRole != 'admin') {
        // Filter for non-admins
        query = query.where('ownerAuthId', isEqualTo: loggedInUserAuthId);
      }

      final snapshot = await query.get(); // Use the query with filtering
      final vehicles = _mapVehicleSnapshots(snapshot); // Use helper function
      debugPrint("[VehicleRepository] Vehicles fetched: $vehicles");

      return vehicles;
    } catch (e) {
      debugPrint("[VehicleRepository] Error fetching vehicles: $e");
      rethrow;
    }
  }

  /// Helper function to map vehicle snapshots to Vehicle objects
  List<Vehicle> _mapVehicleSnapshots(QuerySnapshot snapshot) {
    List<Vehicle> vehicles = [];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data == null) {
        debugPrint("WARNING: Document data is null for document ${doc.id}");
        continue; // Skip this document if data is null
      }

      try {
        final vehicle = Vehicle.fromJson({
          ...data,
          'id': doc.id,  
        });
        debugPrint(
            '[VehicleRepository] Vehicle from JSON (document ${doc.id}): $vehicle');
        vehicles.add(vehicle);
      } catch (e) {
        debugPrint(
            'Error deserializing vehicle (document ${doc.id}): $e, data: $data');
      }
    }
    return vehicles;
  }

  @override
  Future<Vehicle> update(String id, Vehicle vehicle) async {
    debugPrint(
        "[VehicleRepository] Updating vehicle with ID: $id: ${vehicle.toJson()}");

    try {
      await _db.collection("vehicles").doc(id).set(vehicle.toJson());
      debugPrint("[VehicleRepository] Vehicle updated: ${vehicle.toJson()}");
      return vehicle;
    } catch (e) {
      debugPrint("[VehicleRepository] Error updating vehicle: $e");
      rethrow;
    }
  }

  @override
  Future<Vehicle?> delete(String id) async {
    debugPrint("[VehicleRepository] Deleting vehicle with ID: $id");

    try {
      final vehicle = await getById(id);
      if (vehicle != null) {
        await _db.collection("vehicles").doc(id).delete();
        debugPrint("[VehicleRepository] Vehicle deleted: $vehicle");
      } else {
        debugPrint("[VehicleRepository] Vehicle not found for deletion.");
      }

      return vehicle;
    } catch (e) {
      debugPrint("[VehicleRepository] Error deleting vehicle: $e");
      rethrow;
    }
  }
}
