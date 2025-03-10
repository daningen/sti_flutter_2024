import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_repositories/async_http_repos.dart';
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
      emit(PersonLoaded(persons: persons)); // Use named parameter
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

    // Input validation
    if (event.name.trim().isEmpty) {
      final errorMessage = 'Name is required';
      debugPrint('Error creating person: $errorMessage');
      emit(PersonError('Failed to create person: $errorMessage'));
      return; // Stop further execution
    }

    if (event.ssn.trim().isEmpty) {
      final errorMessage = 'SSN is required';
      debugPrint('Error creating person: $errorMessage');
      emit(PersonError('Failed to create person: $errorMessage'));
      return; // Stop further execution
    }

    try {
      final newPerson = Person(
        name: event.name,
        ssn: event.ssn,
      );
      await personRepository.create(newPerson);
      debugPrint('Person created successfully: $newPerson');

      // Reload persons after creating a new one
      add(LoadPersons());
    } catch (e) {
      debugPrint('Error creating person: $e');
      emit(PersonError('Failed to create person: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePerson(
      UpdatePerson event, Emitter<PersonState> emit) async {
    debugPrint(
        'Updating person: ID: ${event.id}, Name: ${event.name}, SSN: ${event.ssn}');
    try {
      final updatedPerson = Person(
        id: event.id,
        name: event.name,
        ssn: event.ssn,
      );
      await personRepository.update(event.id, updatedPerson);
      debugPrint('Person updated successfully: $updatedPerson');
      add(LoadPersons());
    } catch (e) {
      debugPrint('Error updating person: $e');
      emit(PersonError('Failed to update person: $e'));
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
