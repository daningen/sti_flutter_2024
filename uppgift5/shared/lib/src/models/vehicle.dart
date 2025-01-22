import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';

class Vehicle extends Equatable {
  final String id;
  final String licensePlate;
  final String vehicleType;
  final Person? owner; // Assuming `Person` is another class in your project

  /// Constructor
  Vehicle({
    String? id,
    required this.licensePlate,
    required this.vehicleType,
    this.owner,
  }) : id = id ?? const Uuid().v4();

  /// CopyWith method to create a new Vehicle with updated fields
  Vehicle copyWith({
    String? id,
    String? licensePlate,
    String? vehicleType,
    Person? owner,
  }) {
    return Vehicle(
      id: id ?? this.id,
      licensePlate: licensePlate ?? this.licensePlate,
      vehicleType: vehicleType ?? this.vehicleType,
      owner: owner ?? this.owner,
    );
  }

  /// Convert Vehicle to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'licensePlate': licensePlate,
      'vehicleType': vehicleType,
      'owner': owner?.toJson(), // Assuming `toJson` exists in `Person`
    };
  }

  /// Create a Vehicle object from JSON data
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? const Uuid().v4(),
      licensePlate: json['licensePlate'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      owner: json['owner'] != null ? Person.fromJson(json['owner']) : null,
    );
  }

  /// Validation method to ensure Vehicle is valid
  bool isValid() {
    return licensePlate.isNotEmpty && vehicleType.isNotEmpty;
  }

  @override
  String toString() {
    return 'Vehicle{id: $id, licensePlate: $licensePlate, vehicleType: $vehicleType, owner: ${owner?.name ?? 'No Owner'}}';
  }

  /// Equatable properties for value comparison
  @override
  List<Object?> get props => [id, licensePlate, vehicleType, owner];
}
