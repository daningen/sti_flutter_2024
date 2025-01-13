import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

@immutable
sealed class VehicleEvent {}

class LoadVehicles extends VehicleEvent {}

class ReloadVehicles extends VehicleEvent {}

class CreateVehicle extends VehicleEvent {
  final String licensePlate;
  final String vehicleType;

  CreateVehicle({required this.licensePlate, required this.vehicleType, required Vehicle vehicle});
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
class SelectVehicle extends VehicleEvent {
  final Vehicle vehicle;

  SelectVehicle({required this.vehicle});
}

