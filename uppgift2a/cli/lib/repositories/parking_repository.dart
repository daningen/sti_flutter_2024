import 'dart:convert';
import 'package:cli_shared/cli_shared.dart';
import 'package:http/http.dart' as http;

class ParkingRepository implements RepositoryInterface<Parking> {
  final String endpoint = "http://localhost:8080/parkings";

  @override
  @override
  Future<Parking> create(Parking parking) async {
    final url = Uri.parse(endpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parking.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // Success response handling, adjusting for potential message-only responses
      final json = jsonDecode(response.body);
      if (json.containsKey('parking')) {
        return Parking.fromJson(json['parking']);
      } else {
        // Placeholder if no full object is returned, assumes successful creation
        return parking;
      }
    } else {
      throw Exception('Failed to create parking: ${response.body}');
    }
  }

  @override
  Future<List<Parking>> getAll() async {
    final url = Uri.parse(endpoint);
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List;
      return jsonList.map((json) => Parking.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch parkings: ${response.body}');
    }
  }

  @override
  Future<Parking> update(int id, Parking parking) async {
    final url = Uri.parse('$endpoint/$id');
    final response = await http.put(
      url,
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
      final json = jsonDecode(response.body);
      return Parking.fromJson(json);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to delete parking: ${response.body}');
    }
  }

  @override
  Future<Parking?> getById(int id) async {
    final url = Uri.parse('$endpoint/$id');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Parking.fromJson(json);
    } else {
      return null;
    }
  }

  Future<void> stop(int id) async {
    final url = Uri.parse('$endpoint/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'endTime': DateTime.now().toIso8601String()}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to stop parking: ${response.body}');
    }
  }
}
