import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cli/config/config.dart';

Future<void> showParkingSpaces() async {
  print("Fetching parking spaces from server...");

  try {
    // Send GET request to retrieve parking spaces from the server
    final url = Uri.parse(parkingSpacesEndpoint);
    final response = await http.get(url);

    // Check if the response is successful (HTTP status code 200)
    if (response.statusCode == 200) {
      List<dynamic> parkingSpacesJson = jsonDecode(response.body);

      if (parkingSpacesJson.isEmpty) {
        print("Inga parkeringsplatser registrerade.");
      } else {
        print("Lista över alla parkeringsplatser:");
        for (var parkingSpaceJson in parkingSpacesJson) {
          print(
              "ID: ${parkingSpaceJson['id']}, Adress: ${parkingSpaceJson['address']}, Pris per timme: ${parkingSpaceJson['pricePerHour']} kr");
        }
      }
    } else {
      print("Failed to fetch parking spaces: ${response.body}");
    }
  } catch (e) {
    print("Error fetching parking spaces: $e");
  }
}
