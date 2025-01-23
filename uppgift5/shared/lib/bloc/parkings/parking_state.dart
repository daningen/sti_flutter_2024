import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class ParkingState extends Equatable {}

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
  final bool isFilteringActive;

  ParkingLoaded({
    required this.parkings,
    required this.vehicles,
    required this.parkingSpaces,
    required this.availableVehicles,
    required this.availableParkingSpaces,
    this.selectedParking,
    this.isFilteringActive = false,
  });

  ParkingLoaded copyWith({
    List<Parking>? parkings,
    List<Vehicle>? vehicles,
    List<ParkingSpace>? parkingSpaces,
    List<Vehicle>? availableVehicles,
    List<ParkingSpace>? availableParkingSpaces,
    Parking? selectedParking,
    bool? isFilteringActive,
  }) {
    return ParkingLoaded(
      parkings: parkings ?? this.parkings,
      vehicles: vehicles ?? this.vehicles,
      parkingSpaces: parkingSpaces ?? this.parkingSpaces,
      availableVehicles: availableVehicles ?? this.availableVehicles,
      availableParkingSpaces:
          availableParkingSpaces ?? this.availableParkingSpaces,
      selectedParking: selectedParking ?? this.selectedParking,
      isFilteringActive: isFilteringActive ?? this.isFilteringActive,
    );
  }

  @override
  List<Object?> get props => [
        parkings,
        vehicles,
        parkingSpaces,
        availableVehicles,
        availableParkingSpaces,
        selectedParking?.id, // Compare by ID if necessary
        isFilteringActive,
      ];
}

class ParkingError extends ParkingState {
  final String message;

  ParkingError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Utility extension for better debug logging
extension ParkingStateDebug on ParkingState {
  void debugLog() {
    if (this is ParkingLoaded) {
      final state = this as ParkingLoaded;
      debugPrint('[ParkingLoaded] Parkings: ${state.parkings}');
      debugPrint('[ParkingLoaded] Vehicles: ${state.vehicles}');
      debugPrint('[ParkingLoaded] ParkingSpaces: ${state.parkingSpaces}');
      debugPrint('[ParkingLoaded] AvailableVehicles: ${state.availableVehicles}');
      debugPrint(
          '[ParkingLoaded] AvailableParkingSpaces: ${state.availableParkingSpaces}');
      debugPrint('[ParkingLoaded] SelectedParking: ${state.selectedParking}');
    } else if (this is ParkingError) {
      final state = this as ParkingError;
      debugPrint('[ParkingError] Message: ${state.message}');
    } else {
      debugPrint('[ParkingState] Unknown state: $this');
    }
  }
}
