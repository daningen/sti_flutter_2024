import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:cli_shared/cli_shared.dart';

Future<Response> postPersonHandler(Request request) async {
  try {
    final data = await request.readAsString();
    final json = jsonDecode(data);
    var person = Person.fromJson(json);

    person = await personRepository.create(person);
    return Response.ok(jsonEncode(person.toJson()),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create person'}));
  }
}

Future<Response> getPersonsHandler(Request request) async {
  try {
    final persons = await personRepository.getAll();
    return Response.ok(jsonEncode(persons.map((p) => p.toJson()).toList()));
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to retrieve persons'}));
  }
}

// Other handlers like `getPersonHandler`, `updatePersonHandler`, `deletePersonHandler` follow a similar structure
