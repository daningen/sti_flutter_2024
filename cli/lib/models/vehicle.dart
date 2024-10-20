import 'package:cli/models/person.dart';

class Vehicle {
  final int id;
  final String licensePlate;
  final String vehicleType;
  final Person owner;

  // Named constructor with required parameters
  Vehicle({
    required this.id,
    required this.licensePlate,
    required this.vehicleType,
    required this.owner,
  });

  // Convert Vehicle to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'licensePlate': licensePlate,
        'vehicleType': vehicleType,
        'owner': owner.toJson(),
      };

  // Convert JSON to Vehicle object
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'], // Assuming 'id' is provided in the JSON
      licensePlate: json['licensePlate'],
      vehicleType: json['vehicleType'],
      owner: Person.fromJson(json['owner']),
    );
  }

  @override
  String toString() {
    return 'Vehicle{id: $id, licensePlate: $licensePlate, vehicleType: $vehicleType, owner: ${owner.toString()}}';
  }
}
