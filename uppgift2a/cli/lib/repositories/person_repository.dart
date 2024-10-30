import 'dart:convert';
import 'package:cli_shared/cli_shared.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class PersonRepository implements RepositoryInterface<Person> {
  @override
  Future<Person> getById(int id) async {
    final uri = Uri.parse("http://localhost:8080/persons/$id");

    Response response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body);

    return Person.fromJson(json);
  }

  @override
  Future<Person> create(Person person) async {
    // send person serialized as json over http to server at localhost:8080
    print("create person, send call to cli_operations");
    final uri = Uri.parse("http://localhost:8080/persons");

    Response response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(person.toJson()));

    final json = jsonDecode(response.body);

    return Person.fromJson(json);
  }

  @override
  Future<List<Person>> getAll() async {
    final uri = Uri.parse("http://localhost:8080/persons");
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body);

    return (json as List).map((person) => Person.fromJson(person)).toList();
  }

  @override
  Future<Person> delete(int id) async {
    final uri = Uri.parse("http://localhost:8080/persons/$id");

    Response response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body);

    return Person.fromJson(json);
  }

  @override
  Future<Person> update(int id, Person person) async {
    // send person serialized as json over http to server at localhost:8080
    final uri = Uri.parse("http://localhost:8080/persons/$id");

    Response response = await http.put(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(person.toJson()));

    final json = jsonDecode(response.body);

    return Person.fromJson(json);
  }
}
