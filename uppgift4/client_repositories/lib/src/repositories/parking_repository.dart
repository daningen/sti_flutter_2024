import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';

import '../../config.dart';

class ParkingRepository implements RepositoryInterface<Parking> {
  final String endpoint = Config.parkingsEndpoint;

  @override
  Future<Parking> create(Parking parking) async {
    print("[ParkingRepository] Creating a new parking session.");
    final uri = Uri.parse(endpoint);
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parking.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print("[ParkingRepository] Parking created: $json");
      return json.containsKey('parking')
          ? Parking.fromJson(json['parking'])
          : parking;
    } else {
      print("[ParkingRepository] Failed to create parking: ${response.body}");
      throw Exception('Failed to create parking: ${response.body}');
    }
  }

  @override
  Future<List<Parking>> getAll() async {
    print("[ParkingRepository] Fetching all parking sessions.");
    final uri = Uri.parse(endpoint);
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List;
      // print("[ParkingRepository] Parking sessions fetched: $jsonList");
      return jsonList.map((json) => Parking.fromJson(json)).toList();
    } else {
      print("[ParkingRepository] Failed to fetch parkings: ${response.body}");
      throw Exception('Failed to fetch parkings: ${response.body}');
    }
  }

  @override
  Future<Parking> update(int id, Parking parking) async {
    print("[ParkingRepository] Updating parking session with ID: $id");

    final uri = Uri.parse('$endpoint/$id');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parking.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print("[ParkingRepository] Parking updated: $json");
      return Parking.fromJson(json);
    } else {
      print("[ParkingRepository] Failed to update parking: ${response.body}");
      throw Exception('Failed to update parking: ${response.body}');
    }
  }

  @override
  @override
  Future<Parking?> delete(int id) async {
    print("[ParkingRepository] Deleting parking session with ID: $id");
    final uri = Uri.parse('$endpoint/$id');
    final response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print("[ParkingRepository] Parking deleted: $json");
      if (json is Map<String, dynamic> && json.containsKey('message')) {
        return null; // Deletion success message
      } else {
        return Parking.fromJson(json); // Return the deleted object
      }
    } else if (response.statusCode == 404) {
      print("[ParkingRepository] Parking not found for deletion.");
      return null;
    } else {
      print("[ParkingRepository] Failed to delete parking: ${response.body}");
      throw Exception('Failed to delete parking: ${response.body}');
    }
  }

  @override
  @override
  Future<Parking?> getById(int id) async {
    print("[ParkingRepository] Fetching parking session with ID: $id");
    final uri = Uri.parse('$endpoint/$id');
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print("[ParkingRepository] Parking session fetched: $json");
      return Parking.fromJson(json); // Return a valid Parking object.
    } else {
      print("[ParkingRepository] Parking not found with ID: $id");
      return null; // Explicitly return null if not found.
    }
  }

  Future<void> stop(int id) async {
    debugPrint("in ParkingRepository.stop");
    print("[ParkingRepository] Stopping parking session with ID: $id");

    // Use Config.parkingsEndpoint for the base URL
    final uri = Uri.parse('${Config.parkingsEndpoint}/$id/stop');

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'endTime': DateTime.now().toIso8601String()}),
    );

    if (response.statusCode == 200) {
      print("[ParkingRepository] Parking session stopped successfully.");
    } else {
      print("[ParkingRepository] Failed to stop parking: ${response.body}");
      throw Exception('Failed to stop parking: ${response.body}');
    }
  }

  void debugPrint(String s) {}
}
