import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cli/config/config.dart';
import 'package:cli/models/person.dart';

Future<void> showPersons() async {
  print("Fetching persons from server...");

  try {
    // Create the URL for the persons endpoint
    final url = Uri.parse(personsEndpoint);

    // Make the GET request to fetch all persons
    final response = await http.get(url);

    // Check if the response is successful (HTTP status code 200)
    if (response.statusCode == 200) {
      List<dynamic> personsJson = jsonDecode(response.body);

      if (personsJson.isEmpty) {
        print("Inga personer registrerade.");
      } else {
        print("Lista över alla personer:");
        for (var personJson in personsJson) {
          Person person = Person.fromJson(personJson);
          print(
              "ID: ${person.id}, Namn: ${person.name}, Personnummer: ${person.ssn}");
        }
      }
    } else {
      print("Failed to fetch persons: ${response.body}");
    }
  } catch (e) {
    print("Error fetching persons: $e");
  }
}
