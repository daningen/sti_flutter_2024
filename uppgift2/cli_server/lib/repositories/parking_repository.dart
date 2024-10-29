import 'dart:convert';
import 'package:cli_shared/cli_shared.dart';
import 'package:http/http.dart' as http;

class ParkingRepository implements RepositoryInterface<Parking> {
  final String endpoint = "http://localhost:8080/parkings";

  @override
  Future<Parking> create(Parking parking) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parking.toJson()),
    );
    if (response.statusCode == 201) {
      return Parking.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create parking');
    }
  }

  @override
  Future<List<Parking>> getAll() async {
    final response = await http.get(Uri.parse(endpoint));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Parking.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch parkings');
    }
  }

  @override
  Future<Parking?> getById(int id) async {
    final response = await http.get(Uri.parse('$endpoint/$id'));
    if (response.statusCode == 200) {
      return Parking.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  @override
  Future<Parking> update(int id, Parking parking) async {
    final response = await http.put(
      Uri.parse('$endpoint/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parking.toJson()),
    );
    if (response.statusCode == 200) {
      return Parking.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update parking');
    }
  }

  @override
  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$endpoint/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete parking');
    }
  }
}
