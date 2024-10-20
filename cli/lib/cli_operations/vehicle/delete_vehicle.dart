import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cli/config/config.dart'; // Ensure your configuration is properly set up

Future<void> deleteVehicle() async {
  print("Ange ID för fordonet du vill ta bort:");
  String? idInput = stdin.readLineSync();

  // Ensure the input is valid
  if (idInput == null || idInput.isEmpty || int.tryParse(idInput) == null) {
    print("Ogiltigt ID. Vänligen ange ett giltigt ID.");
    return;
  }

  int vehicleId = int.parse(idInput);

  try {
    // Construct the URL with the vehicle ID
    final url = Uri.parse('$vehiclesEndpoint/$vehicleId');

    // Send DELETE request to the server
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print("Fordon med ID $vehicleId har tagits bort.");
    } else if (response.statusCode == 404) {
      print("Fordon med ID $vehicleId hittades inte.");
    } else {
      print("Misslyckades med att ta bort fordonet: ${response.body}");
    }
  } catch (e) {
    print("Ett fel uppstod vid borttagning av fordonet: $e");
  }
}
