import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

@immutable
sealed class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class LoadVehicles extends VehicleEvent {}

class ReloadVehicles extends VehicleEvent {}

class CreateVehicle extends VehicleEvent {
  final String authId;
  final String licensePlate;
  final String vehicleType;
  final String ownerAuthId; // Only ownerAuthId

  CreateVehicle({
    required this.authId,
    required this.licensePlate,
    required this.vehicleType,
    required this.ownerAuthId, // Only ownerAuthId
  });

  @override
  List<Object?> get props => [authId, licensePlate, vehicleType, ownerAuthId]; // Include ownerAuthId in props
}

class UpdateVehicle extends VehicleEvent {
  final String vehicleId;
  final Vehicle updatedVehicle;

  UpdateVehicle({
    required this.vehicleId,
    required this.updatedVehicle,
  });

  @override
  List<Object?> get props => [vehicleId, updatedVehicle];
}

class DeleteVehicle extends VehicleEvent {
  final String vehicleId;

  DeleteVehicle({required this.vehicleId});

  @override
  List<Object?> get props => [vehicleId];
}

class SelectVehicle extends VehicleEvent {
  final Vehicle vehicle;

  SelectVehicle({required this.vehicle});

  @override
  List<Object?> get props => [vehicle];
}