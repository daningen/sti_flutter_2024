import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

@immutable
abstract class ParkingEvent extends Equatable {
  const ParkingEvent();

  @override
  List<Object?> get props => [];
}

class LoadParkings extends ParkingEvent {
  final ParkingFilter filter;

  const LoadParkings({this.filter = ParkingFilter.all});

  @override
  List<Object?> get props => [...super.props, filter];
}

class CreateParking extends ParkingEvent {
  final String vehicleId;
  final String parkingSpaceId;

  const CreateParking({required this.vehicleId, required this.parkingSpaceId});

  @override
  List<Object?> get props => [...super.props, vehicleId, parkingSpaceId];
}

class StopParking extends ParkingEvent {
  final String parkingId;

  const StopParking({required this.parkingId});

  @override
  List<Object?> get props => [...super.props, parkingId];
}

class SelectParking extends ParkingEvent {
  final Parking? selectedParking;

  const SelectParking({this.selectedParking});

  @override
  List<Object?> get props => [...super.props, selectedParking];
}

class UpdateParking extends ParkingEvent {
  final Parking parking;

  const UpdateParking({required this.parking});

  @override
  List<Object?> get props => [...super.props, parking];
}