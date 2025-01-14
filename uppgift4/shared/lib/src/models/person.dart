import 'dart:convert';
import 'package:objectbox/objectbox.dart';
import 'item.dart';

@Entity()
class Person {
  @Id()
  int id;

  String name;
  String ssn;

  List<Item> items;

  String get itemsInDb {
    return jsonEncode(items.map((item) => item.toJson()).toList());
  }

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
      name: json['name'] ?? '',
      ssn: json['ssn'] ?? '',
      id: json['id'] ?? 0,
      items: (json['items'] as List?)
              ?.map((item) => Item.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      "id": id,
      "name": name,
      "ssn": ssn,
    };

    if (items.isNotEmpty) {
      json['items'] = items.map((item) => item.toJson()).toList();
    }

    return json;
  }

  @override
  String toString() {
    return 'Person{id: $id, name: $name, ssn: $ssn, items: ${items.map((e) => e.description).join(', ')}}';
  }
}
