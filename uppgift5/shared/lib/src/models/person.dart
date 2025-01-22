import 'package:uuid/uuid.dart';

class Person {
  String id;
  String name;
  String ssn;

  Person({
    String? id,
    required this.name,
    required this.ssn,
  }) : id = id ?? const Uuid().v4();

  // Factory method to create a Person object from JSON
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] ?? const Uuid().v4(),
      name: json['name'] ?? '',
      ssn: json['ssn'] ?? '',
    );
  }

  // Method to convert a Person object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ssn': ssn,
    };
  }

  // Add the copyWith method
  Person copyWith({
    String? id,
    String? name,
    String? ssn,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      ssn: ssn ?? this.ssn,
    );
  }

  @override
  String toString() {
    return 'Person{id: $id, name: $name, ssn: $ssn}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Person && other.id == id && other.name == name && other.ssn == ssn;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ ssn.hashCode;
}
