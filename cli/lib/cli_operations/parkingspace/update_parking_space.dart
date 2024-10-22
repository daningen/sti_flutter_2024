import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cli/config/config.dart'; // Ensure you have parkingSpacesEndpoint configured
import 'package:cli/models/parking_space.dart';

Future<void> updateParkingSpace() async {
  print("Ange ID för parkeringsplatsen du vill uppdatera:");
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
      ParkingSpace parkingSpaceToUpdate = ParkingSpace(
        id: parkingSpaceJson['id'],
        address: parkingSpaceJson['address'],
        pricePerHour: parkingSpaceJson['pricePerHour'],
      );

      // Prompt for new information to update
      print(
          "Ange ny adress (nuvarande adress: ${parkingSpaceToUpdate.address}):");
      String? newAddress = stdin.readLineSync();
      newAddress ??= parkingSpaceToUpdate.address;

      print(
          "Ange nytt pris per timme (nuvarande pris: ${parkingSpaceToUpdate.pricePerHour} kr/timme):");
      String? newPrice = stdin.readLineSync();
      if (newPrice == null || int.tryParse(newPrice) == null) {
        print("Ogiltigt pris. Uppdatering avbruten.");
        return;
      }
      int updatedPricePerHour = int.parse(newPrice);

      // Create updated ParkingSpace object
      ParkingSpace updatedParkingSpace = ParkingSpace(
        id: parkingSpaceToUpdate.id,
        address: newAddress,
        pricePerHour: updatedPricePerHour,
      );

      // Send a PUT request to update the parking space on the server
      final updateUrl =
          Uri.parse('$parkingSpacesEndpoint/${updatedParkingSpace.id}');
      final updateResponse = await http.put(
        updateUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedParkingSpace.toJson()),
      );

      if (updateResponse.statusCode == 200) {
        print("Parkeringsplats '${updatedParkingSpace.address}' uppdaterad.");
      } else {
        print(
            "Misslyckades med att uppdatera parkeringsplatsen: ${updateResponse.body}");
      }
    } else {
      print("Parkeringsplats med ID '$parkingSpaceId' hittades inte.");
    }
  } catch (e) {
    print("Ett fel uppstod vid uppdateringen av parkeringsplatsen: $e");
  }
}
