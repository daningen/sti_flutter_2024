import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
 
import 'person_event.dart';
import 'person_state.dart';
import 'package:shared/shared.dart';

class PersonBloc extends Bloc<PersonEvent, PersonState> {
  final PersonRepository personRepository;

  PersonBloc({required this.personRepository}) : super(PersonInitial()) {
    on<LoadPersons>(_onLoadPersons);
    on<ReloadPersons>(_onReloadPersons);
    on<CreatePerson>(_onCreatePerson);
    on<UpdatePerson>(_onUpdatePerson);
    on<DeletePerson>(_onDeletePerson);
    on<SelectPerson>(_onSelectPerson);
  }

  Future<void> _onLoadPersons(
      LoadPersons event, Emitter<PersonState> emit) async {
    debugPrint('🔄 Loading persons...');
    emit(PersonLoading());

    try {
      final persons = await personRepository.getAll();
      debugPrint('✅ Fetched persons: ${persons.map((p) => p.toJson()).toList()}');
      emit(PersonLoaded(persons: persons));
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading persons: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(PersonError('Failed to load persons: $e'));
    }
  }

  Future<void> _onReloadPersons(
      ReloadPersons event, Emitter<PersonState> emit) async {
    debugPrint('🔁 Reloading persons...');
    add(LoadPersons());
  }

  Future<void> _onCreatePerson(
    CreatePerson event, Emitter<PersonState> emit) async {
  debugPrint('🆕 Creating person: Name: ${event.name}, SSN: ${event.ssn}');

  if (event.name.trim().isEmpty || event.ssn.trim().isEmpty) {
    emit(PersonError('❌ Name and SSN are required'));
    return;
  }

  try {
    final newPerson = Person(
      id: '', // Let Firestore assign ID
      authId: event.authId, // ✅ Ensure authId is used
      name: event.name,
      ssn: event.ssn,
    );

    final createdPerson = await personRepository.create(newPerson);
    debugPrint('✅ Person created successfully: ${createdPerson.toJson()}');

    if (state is PersonLoaded) {
      final currentState = state as PersonLoaded;
      final updatedList = List.of(currentState.persons)..add(createdPerson);
      emit(currentState.copyWith(persons: updatedList));
    } else {
      add(LoadPersons());
    }
  } catch (e) {
    debugPrint('❌ Error creating person: $e');
    emit(PersonError('Failed to create person: $e'));
  }
}


 Future<void> _onUpdatePerson(
    UpdatePerson event, Emitter<PersonState> emit) async {
  debugPrint('✏️ Updating person: ID: ${event.id}, Name: ${event.name}, SSN: ${event.ssn}');

  if (event.id.trim().isEmpty || event.name.trim().isEmpty || event.ssn.trim().isEmpty) {
    throw Exception('ID, Name, and SSN are required');
  }

  final updatedPerson = Person(
    id: event.id,
    authId: event.authId, // ✅ Ensure authId is used
    name: event.name,
    ssn: event.ssn,
  );

  await personRepository.update(event.id, updatedPerson);
  debugPrint('✅ Person updated successfully: ${updatedPerson.toJson()}');

  if (state is PersonLoaded) {
    final currentState = state as PersonLoaded;
    final updatedList = currentState.persons.map((person) {
      return person.id == event.id ? updatedPerson : person;
    }).toList();
    emit(currentState.copyWith(persons: updatedList));
  } else {
    add(LoadPersons());
  }
}


  Future<void> _onDeletePerson(
      DeletePerson event, Emitter<PersonState> emit) async {
    debugPrint('🗑 Deleting person with ID: ${event.id}');
    try {
      await personRepository.delete(event.id);
      debugPrint('✅ Person deleted successfully: ID: ${event.id}');

      if (state is PersonLoaded) {
        final currentState = state as PersonLoaded;
        final updatedList = currentState.persons
            .where((person) => person.id != event.id)
            .toList();
        emit(currentState.copyWith(persons: updatedList));
      } else {
        add(LoadPersons());
      }
    } catch (e) {
      debugPrint('❌ Error deleting person: $e');
      emit(PersonError('Failed to delete person: $e'));
    }
  }

  Future<void> _onSelectPerson(
      SelectPerson event, Emitter<PersonState> emit) async {
    final currentState = state;
    if (currentState is PersonLoaded) {
      emit(currentState.copyWith(selectedPerson: event.person));
    }
  }
}
