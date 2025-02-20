import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared/shared.dart';

class PersonRepository {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final Uuid uuid = const Uuid();

  /// Fetch a person using Firebase Auth ID
  Future<Person?> getByAuthId(String authId) async {
    debugPrint("[PersonRepository] Fetching person with authId: $authId");

    try {
      final querySnapshot = await db
          .collection("persons")
          .where("authId", isEqualTo: authId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint("[PersonRepository] No person found for authId: $authId");
        return null;
      }

      final data = querySnapshot.docs.first.data();
      return Person.fromJson({...data, "id": querySnapshot.docs.first.id});
    } catch (e) {
      debugPrint("❌ Error fetching person by authId: $e");
      return null;
    }
  }

  /// Fetch all persons from Firestore
  Future<List<Person>> getAll() async {
    debugPrint("[PersonRepository] Fetching all persons...");

    try {
      final querySnapshot = await db.collection("persons").get();

      final persons = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Person.fromJson({...data, "id": doc.id});
      }).toList();

      debugPrint("[PersonRepository] Fetched ${persons.length} persons.");
      return persons;
    } catch (e) {
      debugPrint("❌ Error fetching all persons: $e");
      return [];
    }
  }

  /// Create a new person entry in Firestore, ensuring `authId` is unique
  Future<Person> create(Person person) async {
    debugPrint("[PersonRepository] Checking if person with authId: ${person.authId} exists...");

    try {
      final existingPerson = await getByAuthId(person.authId);
      if (existingPerson != null) {
        debugPrint("[PersonRepository] Person already exists with authId: ${person.authId}");
        return existingPerson;
      }

      debugPrint("[PersonRepository] Creating a new person entry.");

      final personId = uuid.v4(); // Assign new unique ID for Firestore
      final personToCreate = person.copyWith(id: personId);

      await db.collection("persons").doc(personId).set(personToCreate.toJson());

      debugPrint("[PersonRepository] Person created: ${personToCreate.toJson()}");
      return personToCreate;
    } catch (e) {
      debugPrint("❌ Error creating person: $e");
      rethrow;
    }
  }

  /// Update an existing person
  Future<Person?> update(String id, Person person) async {
    debugPrint("[PersonRepository] Updating person with ID: $id");

    try {
      final updatedPerson = person.copyWith(id: id);

      await db
          .collection("persons")
          .doc(id)
          .set(updatedPerson.toJson(), SetOptions(merge: true));

      debugPrint("[PersonRepository] Person updated: ${updatedPerson.toJson()}");
      return updatedPerson;
    } catch (e) {
      debugPrint("❌ Error updating person: $e");
      return null;
    }
  }

  /// Delete a person by ID
  Future<void> delete(String id) async {
    debugPrint("[PersonRepository] Deleting person with ID: $id");

    try {
      await db.collection("persons").doc(id).delete();
      debugPrint("[PersonRepository] Person deleted successfully.");
    } catch (e) {
      debugPrint("❌ Error deleting person: $e");
    }
  }
   Future<Person?> getPersonByAuthId(String authId) async {
    try {
      final querySnapshot = await db
          .collection('persons') // Replace 'persons' with your collection name
          .where('authId', isEqualTo: authId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final personData = querySnapshot.docs.first.data();
        return Person.fromJson(personData);
      } else {
        return null; // Return null if no person is found
      }
    } catch (e) {
      debugPrint("Error fetching person by authId: $e"); // Handle errors
      return null;
    }
  }
}
