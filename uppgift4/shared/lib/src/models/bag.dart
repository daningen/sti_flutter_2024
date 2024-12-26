import 'dart:convert';

import 'package:objectbox/objectbox.dart';

import 'item.dart';

@Entity()
class Bag {
  String description;

  List<Item> items;

  @Id()
  int id;

  String get itemsInDb {
    return jsonEncode(items.map((item) => item.toJson()).toList());
  }

  set itemsInDb(String json) {
    items = (jsonDecode(json) as List)
        .map((jsonItem) => Item.fromJson(jsonItem))
        .toList();
  }

  Bag({required this.description, List<Item>? items, this.id = -1})
      : items = items ?? [];

  factory Bag.fromJson(Map<String, dynamic> json) {
    return Bag(
      description: json['description'],
      id: json['id'],
      items:
          (json['items'] as List).map((json) => Item.fromJson(json)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "description": description,
      "id": id,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
