import 'package:objectbox/objectbox.dart';

@Entity()
class Item {
  String description;

  @Id()
  int id;

  Item(this.description, [this.id = 0]); // Default id to 0 for new entities

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(json['description'], json['id']);
  }

  Map<String, dynamic> toJson() {
    return {"description": description, "id": id};
  }

  Item copyWith({String? description, int? id}) {
    return Item(description ?? this.description, id ?? this.id);
  }
}
