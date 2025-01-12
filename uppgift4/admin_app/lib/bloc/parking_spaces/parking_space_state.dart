import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart'; // Assuming ParkingSpace is defined here

abstract class ParkingSpaceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ParkingSpaceInitial extends ParkingSpaceState {}

class ParkingSpaceLoading extends ParkingSpaceState {}

class ParkingSpaceLoaded extends ParkingSpaceState {
  final List<ParkingSpace> parkingSpaces;

  ParkingSpaceLoaded({required this.parkingSpaces});

  @override
  List<Object?> get props => [parkingSpaces];
}

class ParkingSpaceError extends ParkingSpaceState {
  final String message;

  ParkingSpaceError({required this.message});

  @override
  List<Object?> get props => [message];
}
