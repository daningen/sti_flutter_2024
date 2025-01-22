import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';

class Parking {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final Vehicle? vehicle; // Define the vehicle property
  final ParkingSpace? parkingSpace; // Define the parkingSpace property

  Parking({
    String? id,
    required this.startTime,
    this.endTime,
    this.vehicle,
    this.parkingSpace,
  }) : id = id ??
            const Uuid().v4(); // Automatically generate an ID if not provided

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'vehicle': vehicle?.toJson(), // Assuming `Vehicle` has a `toJson` method
      'parkingSpace': parkingSpace
          ?.toJson(), // Assuming `ParkingSpace` has a `toJson` method
    };
  }

  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['id'] ??
          const Uuid().v4(), // Automatically generate an ID if missing
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      vehicle:
          json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      parkingSpace: json['parkingSpace'] != null
          ? ParkingSpace.fromJson(json['parkingSpace'])
          : null,
    );
  }

  Parking copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    Vehicle? vehicle,
    ParkingSpace? parkingSpace,
  }) {
    return Parking(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      vehicle: vehicle ?? this.vehicle,
      parkingSpace: parkingSpace ?? this.parkingSpace,
    );
  }

  @override
  String toString() {
    return 'Parking{id: $id, startTime: $startTime, endTime: $endTime, vehicle: $vehicle, parkingSpace: $parkingSpace}';
  }
}
