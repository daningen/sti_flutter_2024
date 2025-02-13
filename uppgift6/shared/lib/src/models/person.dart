import 'package:uuid/uuid.dart';

class Person {
  final String id; // Unique Person ID
  final String authId; // Firebase Auth ID
  final String name;
  final String ssn;

  Person({
    required this.id,
    required this.authId,
    required this.name,
    required this.ssn,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] ?? const Uuid().v4(),
      authId: json['authId'] ?? '',
      name: json['name'] ?? '',
      ssn: json['ssn'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authId': authId,
      'name': name,
      'ssn': ssn,
    };
  }

  Person copyWith({
    String? id,
    String? authId,
    String? name,
    String? ssn,
  }) {
    return Person(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      name: name ?? this.name,
      ssn: ssn ?? this.ssn,
    );
  }
}
