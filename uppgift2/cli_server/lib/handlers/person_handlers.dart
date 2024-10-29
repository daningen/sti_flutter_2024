import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:cli_server/repositories/person_repository.dart';

final personRepository = PersonRepository();

// Handler to create a person
Future<Response> postPersonHandler(Request request) async {
  try {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final person = Person.fromJson(data);

    final createdPerson = await personRepository.create(person);

    return Response(201,
        body: jsonEncode(createdPerson.toJson()),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create person'}),
        headers: {'Content-Type': 'application/json'});
  }
}

// Handler to get all persons
Future<Response> getPersonsHandler(Request request) async {
  try {
    final persons = await personRepository.getAll();
    final response =
        jsonEncode(persons.map((person) => person.toJson()).toList());

    return Response.ok(response, headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to retrieve persons'}),
        headers: {'Content-Type': 'application/json'});
  }
}

// Handler to get a specific person by ID
Future<Response> getPersonHandler(Request request) async {
  final id = int.tryParse(request.params['id'] ?? '');
  if (id == null) {
    return Response(400,
        body: jsonEncode({'error': 'Invalid person ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  try {
    final person = await personRepository.getById(id);
    if (person == null) {
      return Response.notFound(jsonEncode({'error': 'Person not found'}),
          headers: {'Content-Type': 'application/json'});
    }

    return Response.ok(jsonEncode(person.toJson()),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to retrieve person'}),
        headers: {'Content-Type': 'application/json'});
  }
}

// Handler to update a person
Future<Response> updatePersonHandler(Request request) async {
  final id = int.tryParse(request.params['id'] ?? '');
  if (id == null) {
    return Response(400,
        body: jsonEncode({'error': 'Invalid person ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  try {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final updatedPersonData = Person.fromJson(data);

    final updatedPerson = await personRepository.update(id, updatedPersonData);
    if (updatedPerson == null) {
      return Response.notFound(jsonEncode({'error': 'Person not found'}),
          headers: {'Content-Type': 'application/json'});
    }

    return Response.ok(jsonEncode(updatedPerson.toJson()),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update person'}),
        headers: {'Content-Type': 'application/json'});
  }
}

// Handler to delete a person by ID
Future<Response> deletePersonHandler(Request request) async {
  final id = int.tryParse(request.params['id'] ?? '');
  if (id == null) {
    return Response(400,
        body: jsonEncode({'error': 'Invalid person ID'}),
        headers: {'Content-Type': 'application/json'});
  }

  try {
    final deletedPerson = await personRepository.delete(id);
    if (deletedPerson == null) {
      return Response.notFound(jsonEncode({'error': 'Person not found'}),
          headers: {'Content-Type': 'application/json'});
    }

    return Response.ok(jsonEncode({'message': 'Person deleted successfully'}),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete person'}),
        headers: {'Content-Type': 'application/json'});
  }
}

// Add routes for person handlers to the router
Router personRouter() {
  final router = Router();

  router.post('/', postPersonHandler);
  router.get('/', getPersonsHandler);
  router.get('/<id|[0-9]+>', getPersonHandler);
  router.put('/<id|[0-9]+>', updatePersonHandler);
  router.delete('/<id|[0-9]+>', deletePersonHandler);

  return router;
}
