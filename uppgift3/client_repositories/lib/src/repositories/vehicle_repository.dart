import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared/shared.dart';

import '../../config.dart';

class VehicleRepository implements RepositoryInterface<Vehicle> {
  final String endpoint = Config.vehiclesEndpoint;

  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    // Send the vehicle as JSON to the server
    // final uri = Uri.parse(vehiclesEndpoint);
    Response response = await http.post(
      // uri,
      Uri.parse(endpoint),
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
    // final uri = Uri.parse('$vehiclesEndpoint/$id');
    Response response = await http.get(
      Uri.parse('$endpoint/$id'),
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
    // final uri = Uri.parse(vehiclesEndpoint);

    Response response = await http.get(
      // uri,
      Uri.parse(endpoint),
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
    // final uri = Uri.parse('$vehiclesEndpoint/$id');
    Response response = await http.put(
      // uri,
      Uri.parse('$endpoint/$id'),
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
    // final uri = Uri.parse('$vehiclesEndpoint/$id');
    Response response = await http.delete(
      Uri.parse('$endpoint/$id'),
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
