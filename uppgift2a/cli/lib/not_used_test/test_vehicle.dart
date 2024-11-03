// // test/vehicle_test.dart

// import 'dart:io';
// import 'package:cli/repositories/vehicle_repository.dart';
// import 'package:cli_shared/cli_shared.dart';

// VehicleRepository repository = VehicleRepository();

// void main() async {
//   print('Vehicle Test - Create a new vehicle');

//   // Get vehicle details from user input (simulating CLI input)
//   print('Enter license plate: ');
//   var licensePlate = stdin.readLineSync();

//   print('Enter vehicle type (car, motorcycle): ');
//   var vehicleType = stdin.readLineSync();

//   print('Enter owner name: ');
//   var ownerName = stdin.readLineSync();

//   print('Enter owner SSN: ');
//   var ownerSSN = stdin.readLineSync();

//   // Validate the input
//   if (licensePlate != null &&
//       vehicleType != null &&
//       ownerName != null &&
//       ownerSSN != null &&
//       licensePlate.isNotEmpty &&
//       vehicleType.isNotEmpty &&
//       ownerName.isNotEmpty &&
//       ownerSSN.isNotEmpty) {
//     // Create the Person object for the vehicle owner
//     var owner = Person(name: ownerName, ssn: ownerSSN);

//     // Create the Vehicle object
//     var vehicle = Vehicle(licensePlate: licensePlate, vehicleType: vehicleType);
//     vehicle.owner.target = owner;

//     // Store the vehicle using the repository
//     try {
//       await repository.create(vehicle);
//       print('Vehicle created successfully: ${vehicle.toJson()}');
//     } catch (e) {
//       print('Failed to create vehicle: $e');
//     }
//   } else {
//     print('Invalid input, all fields are required.');
//   }

//   // Optional: List all vehicles in the repository to verify
//   print('Listing all vehicles:');
//   var allVehicles = await repository.getAll();
//   for (var v in allVehicles) {
//     print(v.toJson());
//   }
// }
