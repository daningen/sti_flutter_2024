import 'package:objectbox/objectbox.dart';
import 'person.dart';

@Entity()
class Vehicle {
  @Id()
  int id;

  String licensePlate;
  String vehicleType;
  final owner = ToOne<Person>();

  Vehicle({this.id = 0, required this.licensePlate, required this.vehicleType});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'licensePlate': licensePlate,
      'vehicleType': vehicleType,
      'owner': owner.target?.toJson(),
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    final vehicle = Vehicle(
      id: json['id'],
      licensePlate: json['licensePlate'],
      vehicleType: json['vehicleType'],
    );
    if (json['owner'] != null) {
      vehicle.owner.target = Person.fromJson(json['owner']);
    }
    return vehicle;
  }
}
