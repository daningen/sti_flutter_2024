import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cli/config/config.dart';

Future<void> showParking() async {
  print("Ange fordonets registreringsnummer:");
  String licensePlate = stdin.readLineSync()!;

  try {
    final url = Uri.parse('$parkingsEndpoint?licensePlate=$licensePlate');
    final response = await http.get(url);

    print("GET response received with status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      // Parse the response as a list of parking sessions
      List<dynamic> parkingList = jsonDecode(response.body);

      if (parkingList.isEmpty) {
        print("Ingen parkering hittad för registreringsnummer: $licensePlate");
        return;
      }

      // Assuming you want to print out the first parking found
      Map<String, dynamic> parkingData = parkingList.first;

      print("Detaljer om din parkering");
      print("Registreingsnummer: ${parkingData['vehicle']['licensePlate']}");
      print("Ägare: ${parkingData['vehicle']['owner']['name']}");
      print("Adress parkering: ${parkingData['parkingSpace']['address']}");
      print("Startid: ${parkingData['startTime']}");
      print(
          "Sluttid: ${parkingData['endTime'] ?? 'Parkering pågår fortfarande'}");
    } else {
      print("Error fetching parking: ${response.body}");
    }
  } catch (e) {
    print("Error while fetching parking: $e");
  }
}
