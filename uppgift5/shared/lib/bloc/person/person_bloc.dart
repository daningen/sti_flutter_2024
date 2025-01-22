import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared/shared.dart';
import 'person_event.dart';
import 'person_state.dart';

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
    debugPrint('Loading persons...');
    emit(PersonLoading());
    try {
      final persons = await personRepository.getAll();
      debugPrint('Fetched persons: $persons');
      emit(PersonLoaded(persons: persons));
    } catch (e) {
      debugPrint('Error loading persons: $e');
      emit(PersonError('Failed to load persons: $e'));
    }
  }

  Future<void> _onReloadPersons(
      ReloadPersons event, Emitter<PersonState> emit) async {
    debugPrint('Reloading persons...');
    add(LoadPersons());
  }

  Future<void> _onCreatePerson(
      CreatePerson event, Emitter<PersonState> emit) async {
    debugPrint('Creating person: Name: ${event.name}, SSN: ${event.ssn}');

    if (event.name.trim().isEmpty) {
      emit(PersonError('Failed to create person: Name is required'));
      return;
    }

    if (event.ssn.trim().isEmpty) {
      emit(PersonError('Failed to create person: SSN is required'));
      return;
    }

    try {
      final newPerson = Person(
        id: '', // ID will be assigned by Firebase
        name: event.name,
        ssn: event.ssn,
      );
      await personRepository.create(newPerson);
      debugPrint('Person created successfully: $newPerson');
      add(LoadPersons());
    } catch (e) {
      debugPrint('Error creating person: $e');
      emit(PersonError('Failed to create person: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePerson(
      UpdatePerson event, Emitter<PersonState> emit) async {
    emit(PersonLoading());
    try {
      // Validate inputs
      if (event.name.isEmpty) {
        throw Exception('Name is required');
      }
      if (event.ssn.isEmpty) {
        throw Exception('SSN is required');
      }

      // Call repository to update the person
      final updatedPerson = await personRepository.update(
        event.id,
        Person(id: event.id, name: event.name, ssn: event.ssn),
      );
      debugPrint('Person updated successfully: $updatedPerson');

      // Reload the list of persons
      final persons = await personRepository.getAll();
      emit(PersonLoaded(persons: persons));
    } catch (e) {
      // Standardize error message formatting
      final message = e.toString().replaceFirst(RegExp(r'^Exception: '), '');
      debugPrint('Error updating person: $message');
      emit(PersonError('Failed to update person: $message'));
    }
  }

  Future<void> _onDeletePerson(
      DeletePerson event, Emitter<PersonState> emit) async {
    debugPrint('Deleting person with ID: ${event.id}');
    try {
      await personRepository.delete(event.id);
      debugPrint('Person deleted successfully: ID: ${event.id}');
      add(LoadPersons());
    } catch (e) {
      debugPrint('Error deleting person: $e');
      emit(PersonError('Failed to delete person: $e'));
    }
  }

  Future<void> _onSelectPerson(
      SelectPerson event, Emitter<PersonState> emit) async {
    final currentState = state;
    if (currentState is PersonLoaded) {
      emit(PersonLoaded(
        persons: currentState.persons,
        selectedPerson: event.person,
      ));
    }
  }
}
