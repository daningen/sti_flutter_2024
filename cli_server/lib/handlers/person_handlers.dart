import 'dart:convert';
import 'package:cli_server/globals.dart'; // For shared repository instances
import 'package:cli_server/models/person.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

// Handler to get all persons
Future<Response> getAllPersonsHandler(Request req) async {
  print("Handling GET /persons");

  List<Person> allPersons = await personRepository.getAll();
  print(
      "Persons retrieved from repository: ${allPersons.map((p) => p.toJson()).toList()}");

  if (allPersons.isEmpty) {
    return Response.ok('[]', headers: {'Content-Type': 'application/json'});
  }

  final jsonResponse = jsonEncode(allPersons.map((p) => p.toJson()).toList());
  return Response.ok(jsonResponse,
      headers: {'Content-Type': 'application/json'});
}

// Handler to get a specific person by ID
Future<Response> getPersonHandler(Request request) async {
  print("Handling GET /persons/<id>");

  final id = int.tryParse(request.params['id']!);

  if (id == null) {
    return Response.notFound(jsonEncode({'error': 'Invalid person ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  final person = await personRepository.getPersonById(id);
  if (person == null) {
    return Response.notFound(jsonEncode({'error': 'Person not found'}),
        headers: {'Content-Type': 'application/json'});
  }

  return Response.ok(jsonEncode(person.toJson()),
      headers: {'Content-Type': 'application/json'});
}

// Handler to add a new person
Future<Response> addPersonHandler(Request req) async {
  try {
    final payload = await req.readAsString();
    print("Handling POST /persons - Received payload: $payload");
    final personData = jsonDecode(payload);

    if (personData.containsKey('name') && personData.containsKey('ssn')) {
      // Generate new ID for the person
      final newId = (await personRepository.getAll()).length + 1;

      // Create the new person object
      final newPerson =
          Person(id: newId, name: personData['name'], ssn: personData['ssn']);
      await personRepository.add(newPerson);

      print(
          "Persons in repository after addition: ${(await personRepository.getAll()).map((p) => p.toJson()).toList()}");

      final jsonResponse = jsonEncode({
        'message': 'Person added successfully',
        'person': newPerson.toJson(),
        'totalPersons': (await personRepository.getAll()).length,
      });

      return Response(201,
          body: jsonResponse, headers: {'Content-Type': 'application/json'});
    } else {
      return Response(400,
          body: jsonEncode({'error': 'Invalid person data'}),
          headers: {'Content-Type': 'application/json'});
    }
  } catch (e, stackTrace) {
    print('Error while adding person: $e');
    print(stackTrace);
    return Response(500,
        body: jsonEncode({'error': 'Internal Server Error'}),
        headers: {'Content-Type': 'application/json'});
  }
}

// Handler to update an existing person by ID
Future<Response> updatePersonHandler(Request request) async {
  print("Handling PUT /persons/<id>");

  final id = int.tryParse(request.params['id']!);

  if (id == null) {
    return Response.notFound(jsonEncode({'error': 'Invalid person ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  final payload = await request.readAsString();
  final personData = jsonDecode(payload);

  final existingPerson = await personRepository.getPersonById(id);
  if (existingPerson == null) {
    return Response.notFound(jsonEncode({'error': 'Person not found'}),
        headers: {'Content-Type': 'application/json'});
  }

  if (personData.containsKey('name') && personData.containsKey('ssn')) {
    final updatedPerson =
        Person(id: id, name: personData['name'], ssn: personData['ssn']);

    await personRepository.updatePerson(id, updatedPerson);

    return Response.ok(
        jsonEncode({
          'message': 'Person updated successfully',
          'person': updatedPerson.toJson(),
        }),
        headers: {'Content-Type': 'application/json'});
  } else {
    return Response(400,
        body: jsonEncode({'error': 'Invalid person data'}),
        headers: {'Content-Type': 'application/json'});
  }
}

// Handler to delete a person by ID
Future<Response> deletePersonHandler(Request request) async {
  print("Handling DELETE /persons/<id>");

  final id = int.tryParse(request.params['id']!); // No need for extensions

  if (id == null) {
    return Response.notFound(jsonEncode({'error': 'Invalid person ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  final existingPerson = await personRepository.getPersonById(id);
  if (existingPerson == null) {
    return Response.notFound(jsonEncode({'error': 'Person not found'}),
        headers: {'Content-Type': 'application/json'});
  }

  await personRepository.deletePersonById(id);

  return Response.ok(jsonEncode({'message': 'Person deleted successfully'}),
      headers: {'Content-Type': 'application/json'});
}
