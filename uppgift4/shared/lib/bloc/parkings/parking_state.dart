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
  final List<ParkingSpace> availableParkingSpaces;
  final Parking? selectedParking;
  final bool isFilteringActive;

  ParkingLoaded({
    required this.parkings,
    required this.vehicles,
    required this.parkingSpaces,
    required this.availableParkingSpaces,
    this.selectedParking,
    this.isFilteringActive = false,
  });

  ParkingLoaded copyWith({
    List<Parking>? parkings,
    List<Vehicle>? vehicles,
    List<ParkingSpace>? parkingSpaces,
    List<ParkingSpace>? availableParkingSpaces,
    Parking? selectedParking,
    bool clearSelectedParking = false, // Add an optional flag
  }) {
    return ParkingLoaded(
      parkings: parkings ?? this.parkings,
      vehicles: vehicles ?? this.vehicles,
      parkingSpaces: parkingSpaces ?? this.parkingSpaces,
      availableParkingSpaces:
          availableParkingSpaces ?? this.availableParkingSpaces,
      selectedParking: clearSelectedParking
          ? null
          : (selectedParking ?? this.selectedParking),
          isFilteringActive: isFilteringActive,
    );
  }

  @override
  List<Object?> get props => [
        parkings,
        vehicles,
        parkingSpaces,
        availableParkingSpaces,
        selectedParking,
        isFilteringActive,
      ];
}

class ParkingError extends ParkingState {
  final String message;

  ParkingError(this.message);

  @override
  List<Object?> get props => [message];
}
