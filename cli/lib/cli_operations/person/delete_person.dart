import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cli/config/config.dart'; // Ensure you have personsEndpoint configured
import 'package:cli/models/person.dart';

Future<void> deletePerson() async {
  print("Ange personnummer för personen du vill ta bort:");
  String ssn = stdin.readLineSync()!;

  try {
    // Fetch the person from the server using SSN
    final url = Uri.parse(
        '$personsEndpoint?ssn=$ssn'); // Assuming the API supports query by SSN
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> personJson = jsonDecode(response.body);

      if (personJson.isEmpty) {
        print("Personen med personnummer '$ssn' hittades inte.");
        return;
      }

      // Convert the JSON to a Person object
      Person personToDelete = Person.fromJson(personJson);

      // Send a DELETE request to delete the person from the server
      final deleteUrl = Uri.parse('$personsEndpoint/${personToDelete.id}');
      final deleteResponse = await http.delete(deleteUrl);

      if (deleteResponse.statusCode == 200) {
        print("Person '${personToDelete.name}' borttagen.");
      } else if (deleteResponse.statusCode == 404) {
        print("Personen kunde inte hittas.");
      } else {
        print("Misslyckades med att ta bort personen: ${deleteResponse.body}");
      }
    } else {
      print("Personen med personnummer '$ssn' hittades inte.");
    }
  } catch (e) {
    print("Ett fel uppstod vid borttagning av personen: $e");
  }
}
