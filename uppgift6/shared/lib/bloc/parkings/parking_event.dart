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

class ChangeFilter extends ParkingEvent {
  final ParkingFilter filter;

  ChangeFilter(this.filter);

  @override
  List<Object> get props => [filter];
}

class CreateParking extends ParkingEvent {
  final Parking parking; // This is the key change

  const CreateParking(this.parking); // Update the constructor

  @override
  List<Object?> get props => [parking]; // Include parking in props
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

class ScheduleParkingNotification extends ParkingEvent {
  final String title;
  final String content;
  final DateTime deliveryTime;
  final String parkingId;

  const ScheduleParkingNotification({
    required this.title,
    required this.content,
    required this.deliveryTime,
    required this.parkingId,
  });

  @override
  List<Object?> get props => [title, content, deliveryTime, parkingId];
}

// Optional state to indicate notification scheduling (in parking_state.dart if needed)
// class NotificationScheduled extends ParkingState {
//   final String parkingId;
//   const NotificationScheduled({required this.parkingId});

//   @override
//   List<Object?> get props => [parkingId];
// }
