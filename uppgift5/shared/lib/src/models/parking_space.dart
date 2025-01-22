import 'package:uuid/uuid.dart';

class ParkingSpace {
  final String id; // id is now a String and uses Uuid
  final String address;
  final int pricePerHour;

  ParkingSpace({
    String? id,
    required this.address,
    required this.pricePerHour,
  }) : id = id ?? const Uuid().v4(); // Generate a unique ID if none is provided

  /// Create a ParkingSpace object from JSON data
  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: json['id'] ?? const Uuid().v4(), // Generate a UUID if id is null
      address: json['address'] ?? '',
      pricePerHour: json['pricePerHour'] ?? 0,
    );
  }

  /// Convert ParkingSpace to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'pricePerHour': pricePerHour,
    };
  }

  @override
  String toString() {
    return 'ParkingSpace{id: $id, address: $address, pricePerHour: $pricePerHour}';
  }

  /// Equality and Hashcode overrides for comparing objects
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ParkingSpace &&
        other.id == id &&
        other.address == address &&
        other.pricePerHour == pricePerHour;
  }

  @override
  int get hashCode => id.hashCode ^ address.hashCode ^ pricePerHour.hashCode;

  /// CopyWith method to clone and modify properties
  ParkingSpace copyWith({
    String? id,
    String? address,
    int? pricePerHour,
  }) {
    return ParkingSpace(
      id: id ?? this.id,
      address: address ?? this.address,
      pricePerHour: pricePerHour ?? this.pricePerHour,
    );
  }
}
