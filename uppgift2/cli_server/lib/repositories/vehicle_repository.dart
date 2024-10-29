import 'dart:convert';
import 'package:cli_shared/cli_shared.dart';
import 'package:http/http.dart' as http;

class VehicleRepository implements RepositoryInterface<Vehicle> {
  final String endpoint = "http://localhost:8080/vehicles";

  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vehicle.toJson()),
    );
    if (response.statusCode == 201) {
      return Vehicle.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create vehicle');
    }
  }

  @override
  Future<List<Vehicle>> getAll() async {
    final response = await http.get(Uri.parse(endpoint));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Vehicle.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch vehicles');
    }
  }

  @override
  Future<Vehicle?> getById(int id) async {
    final response = await http.get(Uri.parse('$endpoint/$id'));
    if (response.statusCode == 200) {
      return Vehicle.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  @override
  Future<Vehicle> update(int id, Vehicle vehicle) async {
    final response = await http.put(
      Uri.parse('$endpoint/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vehicle.toJson()),
    );
    if (response.statusCode == 200) {
      return Vehicle.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update vehicle');
    }
  }

  @override
  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$endpoint/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete vehicle');
    }
  }
}
