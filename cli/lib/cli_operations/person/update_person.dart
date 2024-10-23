import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cli/config/config.dart';
import 'package:cli/models/person.dart';

Future<void> updatePerson() async {
  print("Ange personnummer för personen du vill uppdatera:");
  String ssn = stdin.readLineSync()!;

  try {
    // Hämta lista med personer from the server using SSN
    final url = Uri.parse('$personsEndpoint?ssn=$ssn');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parse the JSON response as a list of persons
      List<dynamic> personsList = jsonDecode(response.body);

      if (personsList.isEmpty) {
        print("Personen med personnummer '$ssn' hittades inte.");
        return;
      }

      // Matchar Person mot SSN
      Map<String, dynamic> personJson =
          personsList.firstWhere((person) => person['ssn'] == ssn);

      // JSON till Personobjekt
      Person personToUpdate = Person.fromJson(personJson);

      print("Ange nytt namn:");
      String newName = stdin.readLineSync()!;

      // Skapa uppdaterat Personobjekt
      Person updatedPerson = Person(
        id: personToUpdate.id,
        name: newName,
        ssn: personToUpdate.ssn,
      );

      //  PUT request uppdatera Person
      final updateUrl = Uri.parse('$personsEndpoint/${personToUpdate.id}');
      final updateResponse = await http.put(
        updateUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedPerson.toJson()),
      );

      if (updateResponse.statusCode == 200) {
        print("Personen uppdaterad!");
      } else {
        print(
            "Misslyckades med att uppdatera personen: ${updateResponse.body}");
      }
    } else {
      print("Personen med personnummer '$ssn' hittades inte.");
    }
  } catch (e) {
    print("Ett fel uppstod vid uppdateringen: $e");
  }
}
