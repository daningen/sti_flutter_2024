
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';

class VehicleRepository implements RepositoryInterface<Vehicle> {
  final db = FirebaseFirestore.instance;

  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    debugPrint("[VehicleRepository] Creating a new vehicle.");

    // Assign a UUID if not already set
    final vehicleId = vehicle.id.isEmpty ? const Uuid().v4() : vehicle.id;

    final vehicleToCreate = vehicle.copyWith(id: vehicleId);

    await db.collection("vehicles").doc(vehicleId).set(vehicleToCreate.toJson());

    debugPrint("[VehicleRepository] Vehicle created: ${vehicleToCreate.toJson()}");
    return vehicleToCreate;
  }

  @override
  Future<Vehicle?> getById(String id) async {
    debugPrint("[VehicleRepository] Fetching vehicle with ID: $id");

    final snapshot = await db.collection("vehicles").doc(id).get();

    final json = snapshot.data();

    if (json == null) {
      debugPrint("[VehicleRepository] Vehicle not found with ID: $id");
      return null;
    }

    json["id"] = snapshot.id;

    final vehicle = Vehicle.fromJson(json);
    debugPrint("[VehicleRepository] Vehicle fetched: $vehicle");
    return vehicle;
  }

  @override
  Future<List<Vehicle>> getAll() async {
    debugPrint("[VehicleRepository] Fetching all vehicles.");

    final snapshots = await db.collection("vehicles").get();

    final vehicles = snapshots.docs.map((doc) {
      final json = doc.data();
      json["id"] = doc.id;
      return Vehicle.fromJson(json);
    }).toList();

    debugPrint("[VehicleRepository] Fetched vehicles: $vehicles");
    return vehicles;
  }

  @override
  Future<Vehicle> update(String id, Vehicle vehicle) async {
    debugPrint("[VehicleRepository] Updating vehicle with ID: $id");

    await db.collection("vehicles").doc(id).set(vehicle.toJson());

    debugPrint("[VehicleRepository] Vehicle updated: ${vehicle.toJson()}");
    return vehicle;
  }

  @override
  Future<Vehicle?> delete(String id) async {
    debugPrint("[VehicleRepository] Deleting vehicle with ID: $id");

    final vehicle = await getById(id);

    if (vehicle != null) {
      await db.collection("vehicles").doc(id).delete();
      debugPrint("[VehicleRepository] Vehicle deleted: $vehicle");
    } else {
      debugPrint("[VehicleRepository] Vehicle not found for deletion.");
    }

    return vehicle;
  }
}
