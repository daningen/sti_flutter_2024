// vehicle_event.dart
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

@immutable
sealed class VehicleEvent {}

class LoadVehicles extends VehicleEvent {}

class CreateVehicle extends VehicleEvent {
  final String licensePlate;
  final String vehicleType; // Add this field

  CreateVehicle({required this.licensePlate, required this.vehicleType});
}

class UpdateVehicle extends VehicleEvent {
  final int vehicleId;
  final Vehicle updatedVehicle;

  UpdateVehicle({required this.vehicleId, required this.updatedVehicle});
}

class DeleteVehicle extends VehicleEvent {
  final int vehicleId;

  DeleteVehicle({required this.vehicleId});
}
