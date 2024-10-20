import 'package:cli/models/person.dart';
import 'package:cli/repositories/repository.dart';

class PersonRepository extends Repository<Person> {
  List<Person> get allItems => items;

  // Search person by SSN (renamed for clarity)
  Future<Person?> getPersonBySecurityNumber(String ssn) async {
    try {
      return items.firstWhere((person) => person.ssn == ssn);
    } catch (e) {
      return null; // Return null if no person is found
    }
  }

  // Get all people in the repository
  Future<List<Person>> getAllPeople() async {
    return await getAll(); // Calls the getAll method from the base Repository class
  }

  // Search person by id
  Future<Person?> getPersonById(int id) async {
    try {
      return items.firstWhere((person) => person.id == id);
    } catch (e) {
      return null; // Return null if no person is found
    }
  }

  // Delete person by id
  Future<bool> deletePersonById(int id) async {
    final initialCount = items.length;
    items.removeWhere((person) => person.id == id);

    // Return true if a person was deleted, false otherwise
    return items.length < initialCount;
  }

  // Update person by id
  Future<bool> updatePerson(int id, Person newPerson) async {
    var index = items.indexWhere((person) => person.id == id);
    if (index != -1) {
      // Ensure the id remains the same during the update
      final updatedPerson = Person(
        id: id, // Keep the original ID
        name: newPerson.name,
        ssn: newPerson.ssn,
      );
      items[index] = updatedPerson;
      return true; // Return true to indicate success
    } else {
      return false; // Return false if the person was not found
    }
  }

  getPersonBySSN(String ssn) {}
}
