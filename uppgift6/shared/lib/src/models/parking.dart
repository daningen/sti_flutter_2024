// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';

class Parking {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final Vehicle? vehicle; // Nullable because it might be missing in the JSON
  final ParkingSpace?
      parkingSpace; // Nullable because it might be missing in the JSON

  Parking({
    String? id,
    required this.startTime,
    this.endTime,
    this.vehicle,
    this.parkingSpace,
  }) : id = id ??
            const Uuid().v4(); // Automatically generate an ID if not provided

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'vehicle': vehicle?.toJson(), // Assuming `Vehicle` has a `toJson` method
      'parkingSpace': parkingSpace
          ?.toJson(), // Assuming `ParkingSpace` has a `toJson` method
    };
  }

  factory Parking.fromJson(Map<String, dynamic> json) {
    debugPrint('[parking model]Parsing Parking from JSON: $json');

    try {
      if (json['startTime'] == null) {
        debugPrint(
            "ERROR: startTime is null in Firestore document. This is not allowed.");
        throw FormatException("startTime cannot be null");
      }

      DateTime startTime = DateTime.parse(json['startTime'] as String);
      DateTime? endTime; // endTime remains nullable

      final vehicle = json['vehicle'] is Map<String, dynamic>
          ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null;
      final parkingSpace = json['parkingSpace'] is Map<String, dynamic>
          ? ParkingSpace.fromJson(json['parkingSpace'] as Map<String, dynamic>)
          : null;

      return Parking(
        id: json['id'] ?? const Uuid().v4(),
        startTime: startTime, // startTime is non-nullable
        endTime: endTime, // endTime is nullable
        vehicle: vehicle,
        parkingSpace: parkingSpace,
      );
    } catch (e) {
      debugPrint('Error parsing Parking JSON: $e, json: $json');
      rethrow;
    }
  }

  Parking copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    Vehicle? vehicle,
    ParkingSpace? parkingSpace,
  }) {
    return Parking(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      vehicle: vehicle ?? this.vehicle,
      parkingSpace: parkingSpace ?? this.parkingSpace,
    );
  }

  @override
  String toString() {
    return 'Parking{id: $id, startTime: $startTime, endTime: $endTime, vehicle: $vehicle, parkingSpace: $parkingSpace}';
  }
}
