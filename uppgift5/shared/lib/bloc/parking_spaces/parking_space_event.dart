import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

abstract class ParkingSpaceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadParkingSpaces extends ParkingSpaceEvent {}

class CreateParkingSpace extends ParkingSpaceEvent {
  final String address;
  final int pricePerHour;

  CreateParkingSpace({required this.address, required this.pricePerHour});

  @override
  List<Object?> get props => [address, pricePerHour];
}

class EditParkingSpace extends ParkingSpaceEvent {
  final String id; // Changed from int to String
  final String address;
  final int pricePerHour;

  EditParkingSpace({
    required this.id,
    required this.address,
    required this.pricePerHour,
  });

  @override
  List<Object?> get props => [id, address, pricePerHour];
}

class DeleteParkingSpace extends ParkingSpaceEvent {
  final String id; // Changed from int to String

  DeleteParkingSpace({required this.id});

  @override
  List<Object?> get props => [id];
}

class SelectParkingSpace extends ParkingSpaceEvent {
  final ParkingSpace? parkingSpace; // Nullable

  SelectParkingSpace({required this.parkingSpace});

  @override
  List<Object?> get props => [parkingSpace];
}
