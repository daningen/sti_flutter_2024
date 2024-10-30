import 'dart:convert';
import 'package:cli_shared/cli_shared.dart';
import 'package:http/http.dart' as http;

class ParkingRepository implements RepositoryInterface<Parking> {
  final String endpoint = "http://localhost:8080/parkings";

  @override
  Future<Parking?> create(Parking parking) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parking.toJson()),
    );
    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Parking.fromJson(json);
    } else {
      throw Exception('Failed to create parking: ${response.body}');
    }
  }

  @override
  Future<List<Parking>> getAll() async {
    final response = await http.get(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Parking.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch parkings: ${response.body}');
    }
  }

  @override
  Future<Parking?> getById(int id) async {
    final response = await http.get(
      Uri.parse('$endpoint/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return Parking.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null; // Return null if the parking is not found
    } else {
      throw Exception('Failed to fetch parking by ID: ${response.body}');
    }
  }

  @override
  Future<Parking?> update(int id, Parking parking) async {
    final response = await http.put(
      Uri.parse('$endpoint/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parking.toJson()),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Parking.fromJson(json);
    } else {
      throw Exception('Failed to update parking: ${response.body}');
    }
  }

  @override
  Future<Parking?> delete(int id) async {
    final url = Uri.parse('$endpoint/$id');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Return the deleted parking object if delete was successful
      return Parking.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null; // Return null if the parking wasn't found
    } else {
      throw Exception('Failed to delete parking: ${response.body}');
    }
  }
}
