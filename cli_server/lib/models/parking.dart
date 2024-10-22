import 'package:cli_server/models/vehicle.dart';
import 'package:cli_server/models/parking_space.dart';

class Parking {
  final int id; // Unique ID for each parking session
  final Vehicle vehicle;
  final ParkingSpace parkingSpace;
  final DateTime startTime;
  DateTime? endTime; // Nullable, optional end time for ongoing parking

  Parking({
    required this.id, // The parking session's unique ID
    required this.vehicle,
    required this.parkingSpace,
    required this.startTime,
    this.endTime, // Optional: Defaults to null for ongoing parking sessions
  });

  // Method to end the parking session
  void endParkingSession() {
    endTime = DateTime.now(); // Set the end time to the current time
  }

  // Method to check if the parking session is still ongoing
  bool isOngoing() {
    return endTime == null;
  }

  // Convert a Parking object to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicle': vehicle.toJson(), // Ensure vehicle has a toJson method
        'parkingSpace':
            parkingSpace.toJson(), // Ensure parkingSpace has a toJson method
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
      };

  @override
  String toString() {
    return 'Parking{id: $id, vehicle: ${vehicle.licensePlate}, parkingSpace: ${parkingSpace.id}, startTime: $startTime, endTime: $endTime}';
  }
}
