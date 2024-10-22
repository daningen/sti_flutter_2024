import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cli/config/config.dart';
import 'package:intl/intl.dart';

Future<void> showParking() async {
  print("Ange fordonets registreringsnummer:");
  String licensePlate =
      stdin.readLineSync()!.toUpperCase(); // Make sure it's uppercase

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

      final startTime = DateTime.parse(parkingData['startTime']);
      final endTime = parkingData['endTime'] != null
          ? DateTime.parse(parkingData['endTime'])
          : null;

      print("Detaljer om din parkering");
      print("Registreingsnummer: ${parkingData['vehicle']['licensePlate']}");
      print("Ägare: ${parkingData['vehicle']['owner']['name']}");
      print("Adress: ${parkingData['parkingSpace']['address']}");

      // Format startTime
      print("Startid: ${DateFormat('yyyy-MM-dd HH:mm').format(startTime)}");

      // Display correct message based on endTime being null or not
      if (endTime == null) {
        print("Sluttid: Parkering pågår fortfarande");
      } else {
        print("Sluttid: ${DateFormat('yyyy-MM-dd HH:mm').format(endTime)}");
      }
    } else {
      print("Error fetching parking: ${response.body}");
    }
  } catch (e) {
    print("Error while fetching parking: $e");
  }
}
