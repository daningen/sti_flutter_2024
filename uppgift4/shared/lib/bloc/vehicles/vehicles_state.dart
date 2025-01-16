import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

abstract class VehicleState extends Equatable {
  final Vehicle? selectedVehicle;

  const VehicleState({this.selectedVehicle});

  @override
  List<Object?> get props => [selectedVehicle];
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<Vehicle> vehicles;

  const VehicleLoaded(this.vehicles, {super.selectedVehicle});

  @override
  List<Object?> get props => [vehicles, selectedVehicle];
}

class VehicleError extends VehicleState {
  final String message;

  const VehicleError(this.message, {super.selectedVehicle});

  @override
  List<Object?> get props => [message, selectedVehicle];
}
