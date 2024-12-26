import 'package:server/router_config.dart';
import 'package:shared/objectbox.g.dart';
import 'package:shared/shared.dart';

class PersonRepository implements RepositoryInterface<Person> {
  // Instantiate the ObjectBox box for storing Person entities
  Box<Person> personBox = ServerConfig.instance.store.box<Person>();

  @override
  Future<Person> create(Person person) async {
    personBox.put(person, mode: PutMode.insert);

    // Return the newly created person
    return person;
  }

  @override
  Future<Person?> getById(int id) async {
    return personBox.get(id);
  }

  @override
  Future<List<Person>> getAll() async {
    return personBox.getAll();
  }

  @override
  Future<Person> update(int id, Person updatedPerson) async {
    // Update the person entity using the provided id
    personBox.put(updatedPerson, mode: PutMode.update);
    return updatedPerson;
  }

  @override
  Future<Person?> delete(int id) async {
    print("in cli_server/person_repository delete ");
    Person? person = personBox.get(id);
    if (person == null) {
      return null; // Return null if the person is not found
    }
    personBox.remove(id);
    return person;
  }
}
