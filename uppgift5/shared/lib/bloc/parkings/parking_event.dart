import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

@immutable
sealed class ParkingEvent {}

class LoadParkings extends ParkingEvent {
  final bool showActiveOnly;
  LoadParkings({this.showActiveOnly = false});
}

class CreateParking extends ParkingEvent {
  final String vehicleId;
  final String parkingSpaceId;
  CreateParking({required this.vehicleId, required this.parkingSpaceId});
}

class StopParking extends ParkingEvent {
  final String parkingId; // Updated from `int` to `String`
  StopParking({required this.parkingId});
}

class SelectParking extends ParkingEvent {
  final Parking? selectedParking;
  SelectParking({required this.selectedParking});
}

class UpdateParking extends ParkingEvent {
  final Parking parking;
  UpdateParking({required this.parking});
}
