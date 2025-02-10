import 'dart:collection';
import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

abstract class VehicleState extends Equatable {
  final Vehicle? selectedVehicle;

  const VehicleState({this.selectedVehicle});

  @override
  List<Object?> get props => [selectedVehicle];
}

/// Initial state when no vehicles are loaded yet
class VehicleInitial extends VehicleState {
  const VehicleInitial({super.selectedVehicle});
}

/// State indicating loading is in progress
class VehicleLoading extends VehicleState {
  const VehicleLoading({super.selectedVehicle});
}

/// State indicating vehicles have been successfully loaded
class VehicleLoaded extends VehicleState {
  final List<Vehicle> _vehicles;

  /// Accessor for an immutable view of the vehicles list
  UnmodifiableListView<Vehicle> get vehicles => UnmodifiableListView(_vehicles);

  VehicleLoaded(
    List<Vehicle> vehicles, {
    super.selectedVehicle,
  }) : _vehicles = vehicles;

  /// Adds a `copyWith` method for creating a new state with updated values.
  VehicleLoaded copyWith({
    List<Vehicle>? vehicles,
    Vehicle? selectedVehicle,
  }) {
    return VehicleLoaded(
      vehicles ?? _vehicles, // Preserve immutability
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
    );
  }

  @override
  List<Object?> get props => [_vehicles, selectedVehicle];
}

/// State indicating an error occurred
class VehicleError extends VehicleState {
  final String message;

  const VehicleError(
    this.message, {
    super.selectedVehicle,
  });

  @override
  List<Object?> get props => [message, selectedVehicle];
}
