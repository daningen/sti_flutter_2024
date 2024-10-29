import 'dart:convert';
import 'package:cli_shared/cli_shared.dart';
import 'package:http/http.dart' as http;

class PersonRepository implements RepositoryInterface<Person> {
  final String endpoint = "http://localhost:8080/persons";

  @override
  Future<Person> create(Person person) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(person.toJson()),
    );
    if (response.statusCode == 201) {
      return Person.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create person');
    }
  }

  @override
  Future<List<Person>> getAll() async {
    final response = await http.get(Uri.parse(endpoint));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Person.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch persons');
    }
  }

  @override
  Future<Person?> getById(int id) async {
    final response = await http.get(Uri.parse('$endpoint/$id'));
    if (response.statusCode == 200) {
      return Person.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  @override
  Future<Person> update(int id, Person person) async {
    final response = await http.put(
      Uri.parse('$endpoint/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(person.toJson()),
    );
    if (response.statusCode == 200) {
      return Person.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update person');
    }
  }

  @override
  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$endpoint/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete person');
    }
  }
}
