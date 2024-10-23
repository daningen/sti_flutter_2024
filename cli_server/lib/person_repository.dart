import 'package:cli_server/models/person.dart';
import 'package:cli_server/repository.dart';

class PersonRepository extends Repository<Person> {
  List<Person> get allItems => items;

  // Search person by SSN (renamed for clarity)
  Future<Person?> getPersonBySecurityNumber(String ssn) async {
    try {
      return items.firstWhere((person) => person.ssn == ssn);
    } catch (e) {
      return null;
    }
  }

  Future<List<Person>> getAllPeople() async {
    return await getAll();
  }

  Future<Person?> getPersonById(int id) async {
    try {
      return items.firstWhere((person) => person.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deletePersonById(int id) async {
    final initialCount = items.length;
    items.removeWhere((person) => person.id == id);

    return items.length < initialCount;
  }

  Future<bool> updatePerson(int id, Person newPerson) async {
    var index = items.indexWhere((person) => person.id == id);
    if (index != -1) {
      final updatedPerson = Person(
        id: id, // Behåll original-ID
        name: newPerson.name,
        ssn: newPerson.ssn,
      );
      items[index] = updatedPerson;
      return true;
    } else {
      return false;
    }
  }
}
