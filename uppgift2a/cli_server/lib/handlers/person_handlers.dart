import 'dart:convert';

import 'package:cli_server/repositories/person_repository.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

PersonRepository repo = PersonRepository();

Future<Response> postPersonHandler(Request request) async {
  try {
    final data = await request.readAsString();
    final json = jsonDecode(data);
    var person = Person.fromJson(json);

    person = await repo.create(person);

    return Response.ok(
      jsonEncode(person.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to create person'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

Future<Response> getPersonsHandler(Request request) async {
  try {
    final persons = await repo.getAll();
    final payload = persons.map((e) => e.toJson()).toList();

    return Response.ok(
      jsonEncode(payload),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to retrieve persons'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

Future<Response> getPersonHandler(Request request) async {
  try {
    final idStr = request.params["id"];
    if (idStr == null) return Response.badRequest(body: 'ID is required');

    final id = int.tryParse(idStr);
    if (id == null) return Response.badRequest(body: 'Invalid ID format');

    final person = await repo.getById(id);
    if (person == null) {
      return Response.notFound(jsonEncode({'error': 'Person not found'}),
          headers: {'Content-Type': 'application/json'});
    }

    return Response.ok(
      jsonEncode(person.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to retrieve person'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

Future<Response> updatePersonHandler(Request request) async {
  try {
    final idStr = request.params["id"];
    if (idStr == null) return Response.badRequest(body: 'ID is required');

    final id = int.tryParse(idStr);
    if (id == null) return Response.badRequest(body: 'Invalid ID format');

    final data = await request.readAsString();
    final json = jsonDecode(data);
    var person = Person.fromJson(json);

    person = await repo.update(id, person);
    return Response.ok(
      jsonEncode(person.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to update person'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

Future<Response> deletePersonHandler(Request request) async {
  try {
    final idStr = request.params["id"];
    if (idStr == null) return Response.badRequest(body: 'ID is required');

    final id = int.tryParse(idStr);
    if (id == null) return Response.badRequest(body: 'Invalid ID format');

    final person = await repo.delete(id);
    if (person == null) {
      return Response.notFound(jsonEncode({'error': 'Person not found'}),
          headers: {'Content-Type': 'application/json'});
    }

    return Response.ok(
      jsonEncode({'message': 'Person deleted', 'person': person.toJson()}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to delete person'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Add or update items for a person
Future<Response> addItemToPersonHandler(Request request) async {
  try {
    final idStr = request.params["id"];
    if (idStr == null) return Response.badRequest(body: 'ID is required');

    final id = int.tryParse(idStr);
    if (id == null) return Response.badRequest(body: 'Invalid ID format');

    final person = await repo.getById(id);
    if (person == null) {
      return Response.notFound(jsonEncode({'error': 'Person not found'}),
          headers: {'Content-Type': 'application/json'});
    }

    final data = await request.readAsString();
    final json = jsonDecode(data);
    final item = Item.fromJson(json);

    person.items.add(item);

    await repo.update(id, person);

    return Response.ok(
      jsonEncode({'message': 'Item added', 'person': person.toJson()}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to add item to person'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Remove an item from a person
Future<Response> removeItemFromPersonHandler(Request request) async {
  try {
    final idStr = request.params["id"];
    if (idStr == null) return Response.badRequest(body: 'ID is required');

    final id = int.tryParse(idStr);
    if (id == null) return Response.badRequest(body: 'Invalid ID format');

    final person = await repo.getById(id);
    if (person == null) {
      return Response.notFound(jsonEncode({'error': 'Person not found'}),
          headers: {'Content-Type': 'application/json'});
    }

    final data = await request.readAsString();
    final json = jsonDecode(data);
    final itemId = json['itemId'];

    person.items.removeWhere((item) => item.id == itemId);

    await repo.update(id, person);

    return Response.ok(
      jsonEncode({'message': 'Item removed', 'person': person.toJson()}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to remove item from person'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}