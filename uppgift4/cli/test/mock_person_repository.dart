
// import 'package:http/http.dart' as http;
// import 'package:shared/shared.dart';

// // Mock implementation of PersonRepository for testing purposes
// class MockPersonRepository implements PersonRepository {
//   @override
//   final String endpoint = ''; // Placeholder endpoint for testing purposes

//   @override
//   final http.Client client =
//       http.Client(); // Mock client; not making actual HTTP requests

//   final Map<int, Person> _personStorage = {};
//   int _nextId = 1;

//   @override
//   Future<Person> create(Person person) async {
//     person.id = _nextId++;
//     _personStorage[person.id] = person;
//     return person;
//   }

//   @override
//   Future<Person> getById(int id) async {
//     return _personStorage[id] ?? Person(name: 'Unknown', ssn: '000000');
//   }

//   @override
//   Future<List<Person>> getAll() async {
//     return _personStorage.values.toList();
//   }

//   @override
//   Future<Person> update(int id, Person person) async {
//     _personStorage[id] = person;
//     return person;
//   }

//   @override
//   Future<Person> delete(int id) async {
//     return _personStorage.remove(id) ?? Person(name: 'Unknown', ssn: '000000');
//   }
// }
