// import 'package:cli/models/person.dart';

// class Vehicle {
//   late String licensePlate;
//   late String vehicleType;
//   late Person owner;

//   // Constructor
//   Vehicle(this.licensePlate, this.vehicleType, Person person) {
//     owner = person;
//   }
// }
import 'package:cli/models/person.dart';

class Vehicle {
  final String licensePlate;
  final String vehicleType;
  final Person owner;

  Vehicle(this.licensePlate, this.vehicleType, this.owner);

  // konvertera vehicle till json
  Map<String, dynamic> toJson() => {
        'licensePlate': licensePlate,
        'vehicleType': vehicleType,
        'owner': owner.toJson(),
      };

  // konvertera json till objekt
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      json['licensePlate'],
      json['vehicleType'],
      Person.fromJson(json['owner']),
    );
  }
}
