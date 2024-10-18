// class Person {
//   final String name;
//   final String ssn; // yymmdd

//   Person({required this.name, required this.ssn});
// }

class Person {
  final String name;
  final String ssn;

  Person({required this.name, required this.ssn});

  // Convert a Person object to JSON
  Map<String, dynamic> toJson() => {
        'name': name,
        'ssn': ssn,
      };

  // Create a Person object from JSON
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'],
      ssn: json['ssn'],
    );
  }
}
