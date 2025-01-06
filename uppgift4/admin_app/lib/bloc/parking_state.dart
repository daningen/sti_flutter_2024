import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

@immutable
sealed class ParkingState {}

class ParkingLoading extends ParkingState {}

class ParkingLoaded extends ParkingState {
  final List<Parking> parkings;
  final List<Vehicle> vehicles; // Include vehicles
  final List<ParkingSpace> parkingSpaces; // Include parking spaces

  ParkingLoaded({
    required this.parkings,
    required this.vehicles,
    required this.parkingSpaces,
  });
}

class ParkingError extends ParkingState {
  final String message;
  ParkingError(this.message);
}
