import 'package:cli/models/parking_space.dart';
import 'package:cli/models/vehicle.dart';

class Parking {
  final int id;
  final Vehicle vehicle;
  final ParkingSpace parkingSpace;
  final DateTime startTime;
  DateTime? endTime; // Sluttid för parkeringen (null om parkeringen pågår)

  Parking({
    required this.id,
    required this.vehicle,
    required this.parkingSpace,
    required this.startTime,
    this.endTime,
  });

  void endParkingSession() {
    endTime = DateTime.now(); // Sätt sluttiden till aktuell tid
  }

  // Kontrollera om parkeringen fortfarande pågår
  bool isOngoing() {
    return endTime == null;
  }

  // Konvertera Parking till JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicle': vehicle.toJson(),
        'parkingSpace': parkingSpace.toJson(),
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
      };

  // Skapa Parking från JSON
  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['id'],
      vehicle: Vehicle.fromJson(json['vehicle']),
      parkingSpace: ParkingSpace.fromJson(json['parkingSpace']),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }

  @override
  String toString() {
    return 'Parking{id: $id, vehicle: ${vehicle.licensePlate}, parkingSpace: ${parkingSpace.id}, startTime: $startTime, endTime: $endTime}';
  }
}
