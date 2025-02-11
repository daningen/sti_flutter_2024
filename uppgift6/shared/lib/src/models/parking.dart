// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class Parking {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final Vehicle? vehicle;
  final ParkingSpace? parkingSpace;

  Parking({
    String? id,
    required this.startTime,
    this.endTime,
    this.vehicle,
    this.parkingSpace,
  }) : id = id ?? const Uuid().v4();

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

      // Handle both DateTime and String for Firestore compatibility
      DateTime startTime = json['startTime'] is String
          ? DateTime.parse(json['startTime'])
          : json['startTime'] as DateTime;

      DateTime? endTime;
      if (json['endTime'] != null) {
        if (json['endTime'] is String) {
          try {
            endTime = DateTime.parse(json['endTime']); // Try parsing string
          } catch (e) {
            debugPrint(
                "Error parsing endTime as String: $e, Raw value: ${json['endTime']}");
            endTime = null; // Default to null if parsing fails
          }
        } else if (json['endTime'] is Timestamp) {
          endTime =
              (json['endTime'] as Timestamp).toDate(); // Firestore Timestamp
        } else if (json['endTime'] is DateTime) {
          endTime = json['endTime']; // Already a DateTime
        }
      }

      final vehicle = json['vehicle'] is Map<String, dynamic>
          ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null;
      final parkingSpace = json['parkingSpace'] is Map<String, dynamic>
          ? ParkingSpace.fromJson(json['parkingSpace'] as Map<String, dynamic>)
          : null;

      return Parking(
        id: json['id'] ?? const Uuid().v4(),
        startTime: startTime,
        endTime: endTime,
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
