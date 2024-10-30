import 'package:objectbox/objectbox.dart';

@Entity()
class ParkingSpace {
  @Id()
  int id;

  String address;
  int pricePerHour; // Use 'int' instead of 'double' for consistency.

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

  @override
  String toString() {
    return 'ParkingSpace{id: $id, address: $address, pricePerHour: $pricePerHour}';
  }
}
