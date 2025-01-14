import 'dart:convert';
import 'package:client_repositories/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';

class PersonRepository implements RepositoryInterface<Person> {
  final String endpoint = Config.personsEndpoint;
  final http.Client client;

  PersonRepository({http.Client? client}) : client = client ?? http.Client();

  @override
  Future<Person> getById(int id) async {
    final uri = Uri.parse('$endpoint/$id');
    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Person.fromJson(json);
      } else {
        throw Exception('Failed to get person with ID $id: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching person: ${e.toString()}');
    }
  }

  @override
  Future<Person> create(Person person) async {
    // final uri = Uri.parse(endpoint);
    try {
      // Debug: Log the payload being sent
      print('Payload sent to backend: ${jsonEncode(person.toJson())}');

      final response = await client.post(
        // uri,
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(person.toJson()),
      );
      print(
          'Response from backend in [person_repo]: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return Person.fromJson(json);
      } else {
        throw Exception('Failed to create person: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating person: ${e.toString()}');
    }
  }

  @override
  Future<List<Person>> getAll() async {
    final uri = Uri.parse(endpoint);
    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return (json as List).map((person) => Person.fromJson(person)).toList();
      } else {
        throw Exception('Failed to fetch persons: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching persons: ${e.toString()}');
    }
  }

  @override
  Future<Person> delete(int id) async {
    final uri = Uri.parse('$endpoint/$id');
    try {
      final response = await client.delete(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Person.fromJson(json);
      } else {
        throw Exception(
            'Failed to delete person with ID $id: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting person: ${e.toString()}');
    }
  }

  @override
  Future<Person> update(int id, Person person) async {
    final uri = Uri.parse('$endpoint/$id');
    try {
      final response = await client.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(person.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Person.fromJson(json);
      } else {
        throw Exception(
            'Failed to update person with ID $id: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating person: ${e.toString()}');
    }
  }
}
