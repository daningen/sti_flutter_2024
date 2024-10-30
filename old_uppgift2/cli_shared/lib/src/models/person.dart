import 'dart:convert';
import 'package:objectbox/objectbox.dart';
import 'item.dart';

@Entity()
class Person {
  @Id()
  int id;

  String name;
  String ssn;

  // List of items associated with this person, stored as a JSON string.
  List<Item> items;

  // Converts the list of items to a JSON string for database storage.
  String get itemsInDb {
    return jsonEncode(items.map((item) => item.toJson()).toList());
  }

  // Converts a JSON string from the database back into a list of items.
  set itemsInDb(String json) {
    items = (jsonDecode(json) as List)
        .map((jsonItem) => Item.fromJson(jsonItem))
        .toList();
  }

  Person(
      {required this.name, required this.ssn, List<Item>? items, this.id = 0})
      : items = items ?? [];

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'] ?? '', // Default to an empty string if null
      ssn: json['ssn'] ?? '', // Default to an empty string if null
      id: json['id'] ?? 0, // Default to 0 if id is not provided
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "ssn": ssn,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Person{id: $id, name: $name, ssn: $ssn, items: ${items.map((e) => e.description).join(', ')}}';
  }
}
