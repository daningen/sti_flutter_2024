import 'package:cli/models/person.dart';

class Vehicle {
  final int id;
  final String licensePlate;
  final String vehicleType;
  final Person owner;

  // Konstruktor med parametrar
  Vehicle({
    required this.id,
    required this.licensePlate,
    required this.vehicleType,
    required this.owner,
  });

  // Konvertera Vehicle till JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'licensePlate': licensePlate,
        'vehicleType': vehicleType,
        'owner': owner.toJson(),
      };

  // Konvertera JSON till Vehicleobjekt
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
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
