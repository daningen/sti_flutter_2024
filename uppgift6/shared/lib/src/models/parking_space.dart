import 'package:uuid/uuid.dart';

class ParkingSpace {
  final String id;
  final String address;
  final int pricePerHour;
  final bool isAvailable; // Added isAvailable

  ParkingSpace({
    String? id,
    required this.address,
    required this.pricePerHour,
    this.isAvailable = true, // Default to true
  }) : id = id ?? const Uuid().v4();

  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: json['id'] ?? const Uuid().v4(),
      address: json['address'] ?? '',
      pricePerHour: json['pricePerHour'] ?? 0,
      isAvailable: json['isAvailable'] as bool? ??
          true, // Added isAvailable and default to true if not present
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'pricePerHour': pricePerHour,
      'isAvailable': isAvailable, // Added isAvailable
    };
  }

  @override
  String toString() {
    return 'ParkingSpace{id: $id, address: $address, pricePerHour: $pricePerHour, isAvailable: $isAvailable}'; // Added isAvailable
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ParkingSpace &&
        other.id == id &&
        other.address == address &&
        other.pricePerHour == pricePerHour &&
        other.isAvailable == isAvailable; // Added isAvailable
  }

  @override
  int get hashCode =>
      id.hashCode ^
      address.hashCode ^
      pricePerHour.hashCode ^
      isAvailable.hashCode; // Added isAvailable

  ParkingSpace copyWith({
    String? id,
    String? address,
    int? pricePerHour,
    bool? isAvailable, // Added isAvailable
  }) {
    return ParkingSpace(
      id: id ?? this.id,
      address: address ?? this.address,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      isAvailable: isAvailable ?? this.isAvailable, // Added isAvailable
    );
  }
}
