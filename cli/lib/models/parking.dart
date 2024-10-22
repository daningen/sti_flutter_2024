import 'package:cli/models/parking_space.dart';
import 'package:cli/models/vehicle.dart';

class Parking {
  final int id; // Unikt ID för varje parkeringssession
  final Vehicle vehicle; // Fordonet som parkeras
  final ParkingSpace parkingSpace; // Parkeringsplatsen där fordonet är parkerat
  final DateTime startTime; // Tidpunkt när parkeringen startade
  DateTime? endTime; // Sluttid för parkeringen (null om parkeringen pågår)

  Parking({
    required this.id,
    required this.vehicle,
    required this.parkingSpace,
    required this.startTime,
    this.endTime,
  });

  // Metod för att avsluta parkeringen
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
