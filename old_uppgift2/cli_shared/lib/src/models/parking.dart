// lib/models/parking.dart
import 'package:objectbox/objectbox.dart';
import 'vehicle.dart';
import 'parking_space.dart';

@Entity()
class Parking {
  @Id()
  int id;

  final ToOne<Vehicle> vehicle; // Relation to Vehicle
  final ToOne<ParkingSpace> parkingSpace; // Relation to ParkingSpace
  final DateTime startTime;
  DateTime? endTime;

  Parking({
    required this.startTime,
    this.endTime,
    this.id = 0,
  })  : vehicle = ToOne<Vehicle>(),
        parkingSpace = ToOne<ParkingSpace>();

  // Method to set the vehicle and parking space after object creation
  void setDetails(Vehicle vehicle, ParkingSpace parkingSpace) {
    this.vehicle.target = vehicle;
    this.parkingSpace.target = parkingSpace;
  }

  // Method to end the parking session by setting the end time
  void endParkingSession() {
    endTime = DateTime.now();
  }

  // Convert Parking to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle':
          vehicle.target?.toJson(), // Convert vehicle to JSON if available
      'parkingSpace': parkingSpace.target
          ?.toJson(), // Convert parking space to JSON if available
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  // Create a Parking object from JSON data
  factory Parking.fromJson(Map<String, dynamic> json) {
    final parking = Parking(
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      id: json['id'] ?? 0,
    );

    // Set the vehicle and parking space from JSON if available
    if (json['vehicle'] != null) {
      parking.vehicle.target = Vehicle.fromJson(json['vehicle']);
    }

    if (json['parkingSpace'] != null) {
      parking.parkingSpace.target = ParkingSpace.fromJson(json['parkingSpace']);
    }

    return parking;
  }

  @override
  String toString() {
    return 'Parking{id: $id, vehicle: ${vehicle.target?.licensePlate ?? 'Unknown'}, '
        'parkingSpace: ${parkingSpace.target?.address ?? 'Unknown'}, '
        'startTime: $startTime, endTime: ${endTime ?? 'Ongoing'}}';
  }
}
