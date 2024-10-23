class Person {
  final int id; // Added id field
  final String name;
  final String ssn; // yymmdd

  Person({
    required this.id,
    required this.name,
    required this.ssn,
  });

  // Konvertera Personobjekt till JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ssn': ssn,
      };

  // Skapa Personobjekt från JSON
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      ssn: json['ssn'],
    );
  }

  @override
  String toString() {
    return 'Person{id: $id, name: $name, ssn: $ssn}';
  }
}
