import 'dart:convert';
import 'package:cli/config.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class PersonRepository implements RepositoryInterface<Person> {
  // Access the endpoint through Config
  final String endpoint = Config.personsEndpoint;

  @override
  Future<Person> getById(int id) async {
    final uri = Uri.parse('$endpoint/$id');
    Response response = await http.get(
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

    Response response = await http.post(
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
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body);
    return (json as List).map((person) => Person.fromJson(person)).toList();
  }

  @override
  Future<Person> delete(int id) async {
    final uri = Uri.parse('$endpoint/$id');

    Response response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body);
    return Person.fromJson(json);
  }

  @override
  Future<Person> update(int id, Person person) async {
    final uri = Uri.parse('$endpoint/$id');

    Response response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(person.toJson()),
    );

    final json = jsonDecode(response.body);
    return Person.fromJson(json);
  }
}
