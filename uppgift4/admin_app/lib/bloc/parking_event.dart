import 'package:flutter/material.dart';

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
  final int parkingId;
  StopParking({required this.parkingId});
}
