import 'package:cli/models/parking_space.dart';
import 'package:cli/models/vehicle.dart';

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

  @override
  String toString() {
    return 'Parking{id: $id, vehicle: ${vehicle.licensePlate}, parkingSpace: ${parkingSpace.id}, startTime: $startTime, endTime: $endTime}';
  }
}
