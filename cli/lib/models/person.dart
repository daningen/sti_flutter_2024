class Person {
  final int id; // Added id field
  final String name;
  final String ssn; // yymmdd

  Person({
    required this.id,
    required this.name,
    required this.ssn,
  });

  // Convert a Person object to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ssn': ssn,
      };

  // Create a Person object from JSON
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'], // Make sure 'id' is passed in JSON
      name: json['name'],
      ssn: json['ssn'],
    );
  }

  @override
  String toString() {
    return 'Person{id: $id, name: $name, ssn: $ssn}';
  }
}
