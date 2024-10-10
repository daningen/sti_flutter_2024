import 'package:dart_application_1/models/person.dart';

import 'repository.dart';

class PersonRepository extends Repository<Person> {
  PersonRepository(this._items);

  List<Person> get items => _items;

  final List<Person> _items;

  void addPerson(Person person) {
    _items.add(person);
  }

  Person? getPersonBySecurityNumber(String ssn) {
    return _items.firstWhere((person) => person.ssn == ssn);
  }

  List<Person> getAllPeople() {
    return _items;
  }

  void updatePerson(int index, Person updatedPerson) {
    if (index >= 0 && index < items.length) {
      items[index] = updatedPerson;
    } else {
      throw RangeError("Invalid index: $index");
    }
  }

  void deletePerson(Person personToDelete) {
    _items.remove(personToDelete);
  }
}
