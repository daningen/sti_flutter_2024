import 'package:uuid/uuid.dart';

class Person {
  final String id; // Unique Person ID
  final String authId; // Firebase Auth ID
  final String name;
  final String ssn;
  final String role; // Role field

  Person({
    required this.id,
    required this.authId,
    required this.name,
    required this.ssn,
    this.role = 'user', // Default value is 'user'
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] ?? const Uuid().v4(),
      authId: json['authId'] ?? '',
      name: json['name'] ?? '',
      ssn: json['ssn'] ?? '',
      role: json['role'] ?? 'user', // Important: Handle role in fromJson as well!
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authId': authId,
      'name': name,
      'ssn': ssn,
      'role': role, // Include role in toJson
    };
  }

  Person copyWith({
    String? id,
    String? authId,
    String? name,
    String? ssn,
    String? role,
  }) {
    return Person(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      name: name ?? this.name,
      ssn: ssn ?? this.ssn,
      role: role ?? this.role,
    );
  }
}