import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';

import '../../config.dart';

class ParkingSpaceRepository implements RepositoryInterface<ParkingSpace> {
  final String endpoint = Config.parkingSpacesEndpoint;

  @override
  Future<ParkingSpace> create(ParkingSpace parkingSpace) async {
    final uri = Uri.parse(endpoint);
    final response = await http.post(
      uri,
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
    final uri = Uri.parse(endpoint);
    final response = await http.get(
      uri,
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
    final uri = Uri.parse('$endpoint/$id');
    final response = await http.put(
      uri,
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
      return null;
    } else {
      throw Exception('Failed to delete parking space: ${response.body}');
    }
  }

  @override
  Future<ParkingSpace?> getById(int id) async {
    final uri = Uri.parse('$endpoint/$id');
    final response = await http.get(
      uri,
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
