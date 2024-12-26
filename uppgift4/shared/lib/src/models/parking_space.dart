import 'package:objectbox/objectbox.dart';

@Entity()
class ParkingSpace {
  @Id()
  int id;

  String address;
  int pricePerHour;
  ParkingSpace(
      {required this.address, required this.pricePerHour, this.id = 0});

  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: json['id'] ?? 0,
      address: json['address'] ?? '',
      pricePerHour: json['pricePerHour'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'pricePerHour': pricePerHour,
    };
  }

// Computed property to check if the parking space is occupied
  bool get isOccupied {
    // Logic to check if the space is occupied
    // For example, you can fetch all parkings and filter active ones
    return false; // Replace with actual logic
  }

  @override
  String toString() {
    return 'ParkingSpace{id: $id, address: $address, pricePerHour: $pricePerHour}';
  }
}
