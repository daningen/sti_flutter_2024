import 'dart:convert';
import 'package:cli_shared/cli_shared.dart';
import 'package:http/http.dart' as http;

class ParkingSpaceRepository implements RepositoryInterface<ParkingSpace> {
  final String endpoint = "http://localhost:8080/parking_spaces";

  @override
  Future<ParkingSpace> create(ParkingSpace parkingSpace) async {
    final url = Uri.parse(endpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parkingSpace.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ParkingSpace.fromJson(json);
    } else {
      throw Exception('Failed to create parking space');
    }
  }

  @override
  Future<List<ParkingSpace>> getAll() async {
    final url = Uri.parse(endpoint);
    final response = await http.get(
      url,
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
    final url = Uri.parse('$endpoint/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parkingSpace.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ParkingSpace.fromJson(json);
    } else {
      throw Exception('Failed to update parking space');
    }
  }

  @override
  Future<ParkingSpace?> delete(int id) async {
    final uri = Uri.parse('$endpoint/$id');
    final response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ParkingSpace.fromJson(json);
    } else if (response.statusCode == 404) {
      return null; // Return null if the parking space wasn't found
    } else {
      throw Exception('Failed to delete parking space: ${response.body}');
    }
  }

  @override
  Future<ParkingSpace?> getById(int id) async {
    final url = Uri.parse('$endpoint/$id');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ParkingSpace.fromJson(json);
    } else {
      return null;
    }
  }
}
