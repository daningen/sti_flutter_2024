import 'dart:convert';

import 'package:client_repositories/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';

class PersonRepository implements RepositoryInterface<Person> {
  // Access the endpoint through Config
  final String endpoint = Config.personsEndpoint;
  final http.Client client;

  // Optional client parameter; defaults to http.Client() for production
  PersonRepository({http.Client? client}) : client = client ?? http.Client();

  @override
  Future<Person> getById(int id) async {
    final uri = Uri.parse('$endpoint/$id');
    final response = await client.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body);
    return Person.fromJson(json);
  }

  @override
  Future<Person> create(Person person) async {
    print("Creating person through cli_operations");
    final uri = Uri.parse(endpoint);

    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(person.toJson()),
    );

    final json = jsonDecode(response.body);
    return Person.fromJson(json);
  }

  @override
  Future<List<Person>> getAll() async {
    final uri = Uri.parse(endpoint);
    final response = await client.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body);
    return (json as List).map((person) => Person.fromJson(person)).toList();
  }

  @override
  Future<Person> delete(int id) async {
    final uri = Uri.parse('$endpoint/$id');

    final response = await client.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body);
    return Person.fromJson(json);
  }

  @override
  Future<Person> update(int id, Person person) async {
    final uri = Uri.parse('$endpoint/$id');

    final response = await client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(person.toJson()),
    );

    final json = jsonDecode(response.body);
    return Person.fromJson(json);
  }
}
