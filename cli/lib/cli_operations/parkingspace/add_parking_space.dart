import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cli/config/config.dart';

Future<void> addParkingSpace() async {
  print("Entering addParkingSpaceToServer");

  // Collect form information for parking space
  // print("Ange parkeringsplatsens ID (siffra):");
  // String? inputId = stdin.readLineSync();
  // if (inputId == null || int.tryParse(inputId) == null) {
  //   print("Ogiltigt ID. Ange ett giltigt nummer.");
  //   return;
  // }
  // int id = int.parse(inputId);
  int id = 1;

  print("Ange adress för parkeringsplatsen:");
  String? address = stdin.readLineSync();
  if (address == null || address.isEmpty) {
    print("Ogiltig adress.");
    return;
  }

  print("Ange pris per timme för parkeringsplatsen:");
  String? inputPrice = stdin.readLineSync();
  if (inputPrice == null || int.tryParse(inputPrice) == null) {
    print("Ogiltigt pris. Ange ett giltigt nummer.");
    return;
  }
  int pricePerHour = int.parse(inputPrice);

  // Create parking space JSON object
  final parkingSpaceJson = {
    'id': id,
    'address': address,
    'pricePerHour': pricePerHour,
  };

  print("Sending POST request to add parking space...");

  try {
    // POST request to add parking space to the server
    final url = Uri.parse(parkingSpacesEndpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parkingSpaceJson),
    );

    print("POST response received with status code: ${response.statusCode}");
    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      print('Server Response: ${responseBody['message']}');
      print('Added Parking Space Details: ${responseBody['parkingSpace']}');
      print(
          'Total Parking Spaces on Server: ${responseBody['totalParkingSpaces']}');
    } else {
      print('Failed to add parking space: ${response.body}');
    }
  } catch (e) {
    print('Error while adding parking space: $e');
  }

  print("Exiting addParkingSpaceToServer");
}
