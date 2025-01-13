import 'package:equatable/equatable.dart';

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
  final int id;
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
  final int id;

  DeleteParkingSpace({required this.id});

  @override
  List<Object?> get props => [id];
}