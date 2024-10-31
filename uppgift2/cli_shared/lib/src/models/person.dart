import 'package:objectbox/objectbox.dart';

@Entity()
class Person {
  @Id()
  int id;

  String name;
  String ssn;

  Person({this.id = 0, required this.name, required this.ssn});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'ssn': ssn};

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(id: json['id'], name: json['name'], ssn: json['ssn']);
  }
}
