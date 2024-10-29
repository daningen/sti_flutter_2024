import 'package:objectbox/objectbox.dart';

@Entity()
class ParkingSpace {
  @Id()
  int id;

  String address;
  int pricePerHour;

  ParkingSpace(
      {this.id = 0, required this.address, required this.pricePerHour});

  Map<String, dynamic> toJson() {
    return {'id': id, 'address': address, 'pricePerHour': pricePerHour};
  }

  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: json['id'],
      address: json['address'],
      pricePerHour: json['pricePerHour'],
    );
  }
}
