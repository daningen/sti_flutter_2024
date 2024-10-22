import 'dart:convert';
import 'package:cli/data/parking_data.dart';
import 'package:http/http.dart' as http;
import 'package:cli/config/config.dart';
import 'package:cli/models/parking.dart';

Future<void> addParking() async {
  print("Entering addParking");

  // Skapa dummyparkering
  Parking parking = generateDummyParking();

  // Skicka objekt till server
  final parkingJson = parking.toJson();
  print("Sending POST request to add parking...");
  try {
    final url = Uri.parse(parkingsEndpoint); // från config.dart
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parkingJson),
    );

    print("POST response received with status code: ${response.statusCode}");
    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      print('Server Response: ${responseBody['message']}');
      print('Added Parking Details: ${responseBody['parking']}');
    } else {
      print('Failed to add parking: ${response.body}');
    }
  } catch (e) {
    print('Error while adding parking: $e');
  }
}
