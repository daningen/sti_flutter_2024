import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

@immutable
sealed class ParkingState extends Equatable {
  const ParkingState();

  @override
  List<Object?> get props => [];
}

class ParkingLoading extends ParkingState {
  @override
  List<Object?> get props => [];
}

class ParkingLoaded extends ParkingState {
  final List<Parking> parkings;
  final List<Vehicle> vehicles;
  final List<ParkingSpace> parkingSpaces;
  final List<Vehicle> availableVehicles;
  final List<ParkingSpace> availableParkingSpaces;
  final Parking? selectedParking;
  final ParkingFilter filter;

  const ParkingLoaded({
    required this.parkings,
    required this.vehicles,
    required this.parkingSpaces,
    required this.availableVehicles,
    required this.availableParkingSpaces,
    this.selectedParking,
    this.filter = ParkingFilter.all,
  });

  ParkingLoaded copyWith({
    List<Parking>? parkings,
    List<Vehicle>? vehicles,
    List<ParkingSpace>? parkingSpaces,
    List<Vehicle>? availableVehicles,
    List<ParkingSpace>? availableParkingSpaces,
    Parking? selectedParking,
    ParkingFilter? filter,
  }) {
    return ParkingLoaded(
      parkings: parkings ?? this.parkings,
      vehicles: vehicles ?? this.vehicles,
      parkingSpaces: parkingSpaces ?? this.parkingSpaces,
      availableVehicles: availableVehicles ?? this.availableVehicles,
      availableParkingSpaces: availableParkingSpaces ?? this.availableParkingSpaces,
      selectedParking: selectedParking ?? this.selectedParking,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [
        parkings,
        vehicles,
        parkingSpaces,
        availableVehicles,
        availableParkingSpaces,
        selectedParking?.id,
        filter,
      ];
}

class ParkingError extends ParkingState {
  final String message;

  const ParkingError(this.message);

  @override
  List<Object?> get props => [message];
}