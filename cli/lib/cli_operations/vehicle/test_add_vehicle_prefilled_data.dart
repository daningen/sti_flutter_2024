import 'dart:convert';
import 'package:http/http.dart' as http;

int nextId = 1; // Starting ID value for vehicles

Future<void> addVehicleTest() async {
  // Create a new vehicle object with client-side generated ID
  final vehicle = {
    'id': nextId++, // Incrementing the ID for each new vehicle
    'licensePlate': 'ABC123',
    'vehicleType': 'Car',
    'owner': {
      'name': 'daning svensson',
      'ssn': '720606' // Example SSN
    }
  };

  // Send the vehicle data to the server
  final response = await http.post(
    Uri.parse('http://localhost:8080/vehicles'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(vehicle),
  );

  // Print the server response
  if (response.statusCode == 201) {
    print('Vehicle added successfully: ${response.body}');
  } else {
    print('Failed to add vehicle: ${response.body}');
  }
}

// void main() async {
//   // Call the function to add a vehicle and print the response from the server
//   await addVehicleTest();
// }
