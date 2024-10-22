class ParkingSpace {
  final int id;
  final String address;
  final int pricePerHour;

  ParkingSpace({
    required this.id,
    required this.address,
    required this.pricePerHour,
  });

  // Convert a ParkingSpace object to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'address': address,
        'pricePerHour': pricePerHour,
      };

  // Create a ParkingSpace object from JSON
  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: json['id'], // Ensure 'id' is included in JSON
      address: json['address'],
      pricePerHour: json['pricePerHour'],
    );
  }

  @override
  String toString() {
    return 'ParkingSpace{id: $id, address: $address, pricePerHour: $pricePerHour}';
  }
}
