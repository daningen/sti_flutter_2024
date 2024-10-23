import 'package:cli/models/person.dart';
import 'package:cli/repositories/repository.dart';

class PersonRepository extends Repository<Person> {
  List<Person> get allItems => items;

  // Sök person på personnummer SSN
  Future<Person?> getPersonBySecurityNumber(String ssn) async {
    try {
      return items.firstWhere((person) => person.ssn == ssn);
    } catch (e) {
      return null;
    }
  }

  // Hämta alla personer
  Future<List<Person>> getAllPeople() async {
    return await getAll();
  }

  // Sök person på id
  Future<Person?> getPersonById(int id) async {
    try {
      return items.firstWhere((person) => person.id == id);
    } catch (e) {
      return null;
    }
  }

  // Ta bort person på id
  Future<bool> deletePersonById(int id) async {
    final initialCount = items.length;
    items.removeWhere((person) => person.id == id);

    return items.length < initialCount;
  }

  // Uppdatera person på ID
  Future<bool> updatePerson(int id, Person newPerson) async {
    var index = items.indexWhere((person) => person.id == id);
    if (index != -1) {
      final updatedPerson = Person(
        id: id, // original ID
        name: newPerson.name,
        ssn: newPerson.ssn,
      );
      items[index] = updatedPerson;
      return true;
    } else {
      return false; // om person inte hittas
    }
  }

  getPersonBySSN(String ssn) {}
}
