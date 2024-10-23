import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cli/config/config.dart';
import 'package:cli/models/person.dart';

Future<void> deletePerson() async {
  print("Ange personnummer för personen du vill ta bort:");
  String ssn = stdin.readLineSync()!;

  try {
    // Hämta person skicka med ssn
    final url = Uri.parse('$personsEndpoint?ssn=$ssn');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parsning av JSON response
      List<dynamic> personsList = jsonDecode(response.body);

      if (personsList.isEmpty) {
        print("Personen med personnummer '$ssn' hittades inte.");
        return;
      }

      // Ta fram person från lista med sökning på SSN
      Map<String, dynamic> personJson =
          personsList.firstWhere((person) => person['ssn'] == ssn);

      // Omvandla JSON till Person objekt
      Person personToDelete = Person.fromJson(personJson);

      // DELETE request
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
