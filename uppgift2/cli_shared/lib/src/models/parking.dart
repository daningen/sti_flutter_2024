import 'package:objectbox/objectbox.dart';
import 'vehicle.dart';
import 'parking_space.dart';

@Entity()
class Parking {
  @Id()
  int id;

  final vehicle = ToOne<Vehicle>();
  final parkingSpace = ToOne<ParkingSpace>();
  @Property(type: PropertyType.date)
  final DateTime startTime;
  @Property(type: PropertyType.date)
  DateTime? endTime;

  Parking({this.id = 0, required this.startTime, this.endTime});

  void endParkingSession() {
    endTime = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle': vehicle.target?.toJson(),
      'parkingSpace': parkingSpace.target?.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  factory Parking.fromJson(Map<String, dynamic> json) {
    final parking = Parking(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
    if (json['vehicle'] != null) {
      parking.vehicle.target = Vehicle.fromJson(json['vehicle']);
    }
    if (json['parkingSpace'] != null) {
      parking.parkingSpace.target = ParkingSpace.fromJson(json['parkingSpace']);
    }
    return parking;
  }
}
