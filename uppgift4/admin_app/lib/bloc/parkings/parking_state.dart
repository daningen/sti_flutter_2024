import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:equatable/equatable.dart';

@immutable
sealed class ParkingState extends Equatable {}

class ParkingLoading extends ParkingState {
  @override
  List<Object?> get props => [];
}

class ParkingLoaded extends ParkingState {
  final List<Parking> parkings;
  final List<Vehicle> vehicles;
  final List<ParkingSpace> parkingSpaces;
  final Parking? selectedParking;

  ParkingLoaded({
    required this.parkings,
    required this.vehicles,
    required this.parkingSpaces,
    this.selectedParking,
  });

  ParkingLoaded copyWith({
    List<Parking>? parkings,
    List<Vehicle>? vehicles,
    List<ParkingSpace>? parkingSpaces,
    Parking? selectedParking,
  }) {
    return ParkingLoaded(
      parkings: parkings ?? this.parkings,
      vehicles: vehicles ?? this.vehicles,
      parkingSpaces: parkingSpaces ?? this.parkingSpaces,
      selectedParking: selectedParking,
    );
  }

  @override
  List<Object?> get props =>
      [parkings, vehicles, parkingSpaces, selectedParking];
}

class ParkingError extends ParkingState {
  final String message;

  ParkingError(this.message);

  @override
  List<Object?> get props => [message];
}
