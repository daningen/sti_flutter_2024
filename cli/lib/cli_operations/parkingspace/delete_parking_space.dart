import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cli/config/config.dart'; // Ensure you have parkingSpacesEndpoint configured
import 'package:cli/models/parking_space.dart';

Future<void> deleteParkingSpace() async {
  print("Ange parkeringsplats-ID som du vill ta bort:");
  String? inputId = stdin.readLineSync();
  if (inputId == null || int.tryParse(inputId) == null) {
    print("Ogiltigt ID.");
    return;
  }
  int parkingSpaceId = int.parse(inputId);

  try {
    // Fetch the parking space from the server using ID
    final url = Uri.parse('$parkingSpacesEndpoint/$parkingSpaceId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> parkingSpaceJson = jsonDecode(response.body);

      if (parkingSpaceJson.isEmpty) {
        print("Parkeringsplats med ID '$parkingSpaceId' hittades inte.");
        return;
      }

      // Convert the JSON to a ParkingSpace object
      ParkingSpace parkingSpaceToDelete = ParkingSpace(
        id: parkingSpaceJson['id'],
        address: parkingSpaceJson['address'],
        pricePerHour: parkingSpaceJson['pricePerHour'],
      );

      // Send a DELETE request to delete the parking space from the server
      final deleteUrl =
          Uri.parse('$parkingSpacesEndpoint/${parkingSpaceToDelete.id}');
      final deleteResponse = await http.delete(deleteUrl);

      if (deleteResponse.statusCode == 200) {
        print("Parkeringsplats '${parkingSpaceToDelete.address}' borttagen.");
      } else if (deleteResponse.statusCode == 404) {
        print("Parkeringsplatsen kunde inte hittas.");
      } else {
        print(
            "Misslyckades med att ta bort parkeringsplatsen: ${deleteResponse.body}");
      }
    } else {
      print("Parkeringsplatsen med ID '$parkingSpaceId' hittades inte.");
    }
  } catch (e) {
    print("Ett fel uppstod vid borttagning av parkeringsplatsen: $e");
  }
}
