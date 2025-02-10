import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

@immutable
sealed class VehicleEvent {}

class LoadVehicles extends VehicleEvent {}

class ReloadVehicles extends VehicleEvent {}

class CreateVehicle extends VehicleEvent {
  final String licensePlate;
  final String vehicleType;
  final Person owner;

  CreateVehicle({
    required this.licensePlate,
    required this.vehicleType,
    required this.owner,
  });
}

class UpdateVehicle extends VehicleEvent {
  final String vehicleId; // Updated to String to match Vehicle model
  final Vehicle updatedVehicle;

  UpdateVehicle({
    required this.vehicleId,
    required this.updatedVehicle,
  });
}

class DeleteVehicle extends VehicleEvent {
  final String vehicleId; // Updated to String to match Vehicle model

  DeleteVehicle({required this.vehicleId});
}

class SelectVehicle extends VehicleEvent {
  final Vehicle vehicle;

  SelectVehicle({required this.vehicle});
}
