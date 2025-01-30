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
    debugPrint('Loading persons...');
    emit(PersonLoading()); // Indicate that loading has started

    try {
      // Fetch persons from the repository
      final persons = await personRepository.getAll();

      // Debug log the fetched persons for verification
      debugPrint(
          'Fetched persons from repository: ${persons.map((p) => p.toJson()).toList()}');

      // Emit the loaded state with the fetched persons
      emit(PersonLoaded(persons: persons));

      // Log the state after emitting to verify it's correct
      debugPrint('Emitted PersonLoaded state: $persons');
    } catch (e, stackTrace) {
      // Log error with stack trace for better debugging
      debugPrint('Error loading persons: $e');
      debugPrint('Stack trace: $stackTrace');

      // Emit an error state with the failure message
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

      // Update state directly if already loaded
      if (state is PersonLoaded) {
        final currentState = state as PersonLoaded;
        final updatedList = List.of(currentState.persons)..add(newPerson);
        emit(currentState.copyWith(persons: updatedList));
      } else {
        add(LoadPersons()); // Fallback to reload if state isn't PersonLoaded
      }
    } catch (e) {
      debugPrint('Error creating person: $e');
      emit(PersonError('Failed to create person: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePerson(
      UpdatePerson event, Emitter<PersonState> emit) async {
    try {
      // Debugging inputs
      debugPrint('Starting update operation...');
      debugPrint('Input ID: ${event.id}');
      debugPrint('Input Name: ${event.name}');
      debugPrint('Input SSN: ${event.ssn}');

      // Validate inputs
      if (event.id.trim().isEmpty) {
        throw Exception('ID is required for updating a person');
      }
      if (event.name.trim().isEmpty) {
        throw Exception('Name is required');
      }
      if (event.ssn.trim().isEmpty) {
        throw Exception('SSN is required');
      }

      // Create updated person object
      final updatedPerson = Person(
        id: event.id,
        name: event.name,
        ssn: event.ssn,
      );

      debugPrint('Updating person in repository...');
      await personRepository.update(event.id, updatedPerson);
      debugPrint('Person updated successfully: $updatedPerson');

      // Update the local state
      if (state is PersonLoaded) {
        final currentState = state as PersonLoaded;

        debugPrint('Current state before update: ${currentState.persons}');
        final updatedList = currentState.persons.map((person) {
          return person.id == event.id ? updatedPerson : person;
        }).toList();
        emit(currentState.copyWith(persons: updatedList));
        debugPrint('State updated successfully with updated list.');
      } else {
        debugPrint(
            'State is not PersonLoaded. Reloading persons from repository...');
        add(LoadPersons());
      }
    } catch (e) {
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

      // Update state directly
      if (state is PersonLoaded) {
        final currentState = state as PersonLoaded;
        final updatedList = currentState.persons
            .where((person) => person.id != event.id)
            .toList();
        emit(currentState.copyWith(persons: updatedList));
      } else {
        add(LoadPersons()); // Reload if state isn't PersonLoaded
      }
    } catch (e) {
      debugPrint('Error deleting person: $e');
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
