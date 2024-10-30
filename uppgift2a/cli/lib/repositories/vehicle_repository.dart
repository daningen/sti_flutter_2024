import 'dart:convert';
import 'package:cli_shared/cli_shared.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class VehicleRepository implements RepositoryInterface<Vehicle> {
  // Define the base URL for the server
  final String baseUrl = 'http://localhost:8080';
  // Define a getter for the vehicles endpoint
  String get vehiclesEndpoint => '$baseUrl/vehicles';

  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    // Send the vehicle as JSON to the server
    final uri = Uri.parse(vehiclesEndpoint);
    Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vehicle.toJson()),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Vehicle.fromJson(json);
    } else {
      throw Exception('Failed to create vehicle: ${response.body}');
    }
  }

  @override
  Future<Vehicle?> getById(int id) async {
    final uri = Uri.parse('$vehiclesEndpoint/$id');
    Response response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Vehicle.fromJson(json);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to get vehicle: ${response.body}');
    }
  }

  @override
  Future<List<Vehicle>> getAll() async {
    final uri = Uri.parse(vehiclesEndpoint);
    Response response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      return json.map((v) => Vehicle.fromJson(v)).toList();
    } else {
      throw Exception('Failed to retrieve vehicles: ${response.body}');
    }
  }

  @override
  Future<Vehicle> update(int id, Vehicle updatedVehicle) async {
    final uri = Uri.parse('$vehiclesEndpoint/$id');
    Response response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedVehicle.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Vehicle.fromJson(json);
    } else {
      throw Exception('Failed to update vehicle: ${response.body}');
    }
  }

  @override
  Future<Vehicle?> delete(int id) async {
    final uri = Uri.parse('$vehiclesEndpoint/$id');
    Response response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Vehicle.fromJson(json);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to delete vehicle: ${response.body}');
    }
  }
}
