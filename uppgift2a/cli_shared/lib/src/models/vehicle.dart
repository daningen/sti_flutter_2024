// lib/models/vehicle.dart
import 'package:cli_shared/cli_shared.dart';

@Entity()
class Vehicle {
  @Id()
  int id;

  String licensePlate;
  String vehicleType; // e.g., 'car', 'motorcycle'

  final ToOne<Person> owner;

  Vehicle({
    required this.licensePlate,
    required this.vehicleType,
    this.id = 0,
  }) : owner = ToOne<Person>();

  // Method to set the owner after creation
  void setOwner(Person person) {
    owner.target = person;
  }

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
      licensePlate: json['licensePlate'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      id: json['id'] ?? 0,
    );

    if (json['owner'] != null) {
      vehicle.owner.target = Person.fromJson(json['owner']);
    }

    return vehicle;
  }

  @override
  String toString() {
    return 'Vehicle{id: $id, licensePlate: $licensePlate, vehicleType: $vehicleType, owner: ${owner.target?.name ?? 'No Owner'}}';
  }
}
