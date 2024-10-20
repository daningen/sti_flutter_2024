import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cli/cli_operations/person/collect_person_information.dart';
import 'package:cli/config/config.dart';

Future<void> addPerson() async {
  print("Entering addPerson");

  // Collect form information
  Map<String, String> personInput = await collectPersonInput();

  // Uncommented for debugging purposes, to ensure map is populated correctly
  print("Collected person information: $personInput");

  // Create the JSON object for the person
  final personJson = {
    'name': personInput['name'],
    'ssn': personInput['ssn'],
  };

  print("Sending POST request to add person...");

  try {
    // POST request to add person to the server
    final url = Uri.parse(
        personsEndpoint); // Ensure this endpoint is set up in config.dart
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(personJson),
    );

    print("POST response received with status code: ${response.statusCode}");
    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      print('Server Response: ${responseBody['message']}');
      print('Added Person Details: ${responseBody['person']}');
      print('Total Persons on Server: ${responseBody['totalPersons']}');
    } else {
      print('Failed to add person: ${response.body}');
    }
  } catch (e) {
    print('Error while adding person: $e');
  }

  print("Exiting addPerson");
}
