import 'package:uuid/uuid.dart';

class Item {
  String description;
  String id;

  Item(this.description, [String? id]) : id = id ?? const Uuid().v4();

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      json['description'] ?? '',
      json['id'], // Expecting 'id' to be a string
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
    };
  }

  @override
  String toString() => 'Item{id: $id, description: $description}';
}
