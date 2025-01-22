import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared/shared.dart';

class PersonRepository implements RepositoryInterface<Person> {
  final db = FirebaseFirestore.instance;
  final uuid = const Uuid();

  @override
  Future<Person?> getById(String id) async {
    debugPrint("[PersonRepository] Fetching person with ID: $id");

    final snapshot = await db.collection("persons").doc(id).get();

    final json = snapshot.data();

    if (json == null) {
      debugPrint("[PersonRepository] Person not found with ID: $id");
      return null;
    }

    json["id"] = snapshot.id;

    final person = Person.fromJson(json);
    debugPrint("[PersonRepository] Person fetched: $person");
    return person;
  }

  @override
  Future<Person> create(Person person) async {
    debugPrint("[PersonRepository] Creating a new person.");

    // Assign a UUID if not already set
    final personId = person.id.isEmpty ? uuid.v4() : person.id;

    final personToCreate = person.copyWith(id: personId);

    await db.collection("persons").doc(personId).set(personToCreate.toJson());

    debugPrint("[PersonRepository] Person created: ${personToCreate.toJson()}");
    return personToCreate;
  }

  @override
  Future<List<Person>> getAll() async {
    debugPrint("[PersonRepository] Fetching all persons.");

    final snapshots = await db.collection("persons").get();

    final persons = snapshots.docs.map((doc) {
      final json = doc.data();
      json["id"] = doc.id;
      return Person.fromJson(json);
    }).toList();

    debugPrint("[PersonRepository] Fetched persons: $persons");
    return persons;
  }

  @override
  Future<Person?> delete(String id) async {
    debugPrint("[PersonRepository] Deleting person with ID: $id");

    final person = await getById(id);

    if (person != null) {
      await db.collection("persons").doc(id).delete();
      debugPrint("[PersonRepository] Person deleted: $person");
    } else {
      debugPrint("[PersonRepository] Person not found for deletion.");
    }

    return person;
  }

  @override
  Future<Person> update(String id, Person person) async {
    debugPrint("[PersonRepository] Updating person with ID: $id");

    await db.collection("persons").doc(id).set(person.toJson());

    debugPrint("[PersonRepository] Person updated: ${person.toJson()}");
    return person;
  }
}
