import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';

import '../../config.dart';

class ParkingRepository implements RepositoryInterface<Parking> {
  final String endpoint = Config.parkingsEndpoint;

  @override
  Future<Parking> create(Parking parking) async {
    print("posting parking from client");
    final uri = Uri.parse(endpoint);
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parking.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json.containsKey('parking')
          ? Parking.fromJson(json['parking'])
          : parking;
    } else {
      throw Exception('Failed to create parking: ${response.body}');
    }
  }

  @override
  Future<List<Parking>> getAll() async {
    final uri = Uri.parse(endpoint);
    final response = await http.get(
      uri,
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
    final uri = Uri.parse('$endpoint/$id');
    final response = await http.put(
      uri,
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
    final uri = Uri.parse('$endpoint/$id');
    final response = await http.delete(
      uri,
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
    final uri = Uri.parse('$endpoint/$id');
    final response = await http.get(
      uri,
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
    final uri = Uri.parse('$endpoint/$id');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'endTime': DateTime.now().toIso8601String()}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to stop parking: ${response.body}');
    }
  }
}
