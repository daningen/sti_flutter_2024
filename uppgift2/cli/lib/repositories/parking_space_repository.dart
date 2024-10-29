import 'dart:convert';
import 'package:cli_shared/cli_shared.dart';
import 'package:http/http.dart' as http;

class ParkingSpaceRepository implements RepositoryInterface<ParkingSpace> {
  final String endpoint = "http://localhost:8080/parking_spaces";

  @override
  Future<ParkingSpace> create(ParkingSpace parkingSpace) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parkingSpace.toJson()),
    );

    if (response.statusCode == 201) {
      return ParkingSpace.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create parking space');
    }
  }

  @override
  Future<List<ParkingSpace>> getAll() async {
    final response = await http.get(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List;
      return jsonList.map((json) => ParkingSpace.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch parking spaces');
    }
  }

  @override
  Future<ParkingSpace> update(int id, ParkingSpace parkingSpace) async {
    final response = await http.put(
      Uri.parse('$endpoint/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parkingSpace.toJson()),
    );

    if (response.statusCode == 200) {
      return ParkingSpace.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update parking space');
    }
  }

  @override
  Future<ParkingSpace?> delete(int id) async {
    final response = await http.delete(
      Uri.parse('$endpoint/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ParkingSpace.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to delete parking space');
    }
  }

  @override
  Future<ParkingSpace?> getById(int id) async {
    final response = await http.get(
      Uri.parse('$endpoint/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ParkingSpace.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }
}
