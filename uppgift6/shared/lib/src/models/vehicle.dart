import 'package:equatable/equatable.dart';
 
import 'package:uuid/uuid.dart';

class Vehicle extends Equatable {
  final String id;
  final String authId; // Firebase Auth ID of the user who created the vehicle
  final String licensePlate;
  final String vehicleType;
  final String ownerAuthId; // Auth ID of the vehicle owner

  

  /// Constructor
  Vehicle({
    String? id,
    required this.authId,
    required this.licensePlate,
    required this.vehicleType,
    required this.ownerAuthId, // Changed to ownerAuthId
  }) : id = id ?? const Uuid().v4();

  /// CopyWith method to create a new Vehicle with updated fields
  Vehicle copyWith({
    String? id,
    String? authId,
    String? licensePlate,
    String? vehicleType,
    String? ownerAuthId, // Changed to ownerAuthId
  }) {
    return Vehicle(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      licensePlate: licensePlate ?? this.licensePlate,
      vehicleType: vehicleType ?? this.vehicleType,
      ownerAuthId: ownerAuthId ?? this.ownerAuthId, // Changed to ownerAuthId
    );
  }

  /// Convert Vehicle to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authId': authId,
      'licensePlate': licensePlate,
      'vehicleType': vehicleType,
      'ownerAuthId': ownerAuthId, // Changed to ownerAuthId
    };
  }

  /// Create a Vehicle object from JSON data
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? const Uuid().v4(),
      authId: json['authId'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      ownerAuthId: json['ownerAuthId'] ?? '', // Changed to ownerAuthId
    );
  }

  /// Validation method to ensure Vehicle is valid
  bool isValid() {
    return authId.isNotEmpty &&
        licensePlate.isNotEmpty &&
        vehicleType.isNotEmpty &&
        ownerAuthId.isNotEmpty; // Check ownerAuthId
  }

  @override
  String toString() {
    return 'Vehicle{id: $id, authId: $authId, licensePlate: $licensePlate, vehicleType: $vehicleType, ownerAuthId: $ownerAuthId}'; // Corrected toString
  }

  /// Equatable properties for value comparison
  @override
  List<Object?> get props =>
      [id, authId, licensePlate, vehicleType, ownerAuthId]; // Add ownerAuthId to props
}