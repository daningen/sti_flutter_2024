import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:shared/bloc/person/person_bloc.dart';
import 'package:shared/bloc/person/person_event.dart';
import 'package:shared/bloc/person/person_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/shared.dart';

class MockPersonRepository extends Mock implements PersonRepository {}

class FakePerson extends Fake implements Person {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakePerson());
  });

  group('PersonBloc - UpdatePerson', () {
    late MockPersonRepository personRepository;
    late PersonBloc personBloc;

    setUp(() {
      personRepository = MockPersonRepository();
      personBloc = PersonBloc(personRepository: personRepository);
    });

    tearDown(() {
      personBloc.close();
    });

    blocTest<PersonBloc, PersonState>(
      'updates a person and reloads persons',
      setUp: () {
        when(() => personRepository.update(any(), any())).thenAnswer(
          (_) async => Person(name: 'Updated Name', ssn: '660606', id: '1'),
        );
        when(() => personRepository.getAll()).thenAnswer(
          (_) async => [Person(name: 'Updated Name', ssn: '660606', id: '1')],
        );
      },
      build: () => personBloc,
      act: (bloc) => bloc.add(
        UpdatePerson(id: '1', name: 'Updated Name', ssn: '660606'),
      ),
      expect: () => [
        PersonLoading(),
        isA<PersonLoaded>(),
      ],
      verify: (_) {
        verify(() => personRepository.update(any(), any())).called(1);
        verify(() => personRepository.getAll()).called(1);
      },
    );

    blocTest<PersonBloc, PersonState>(
      'fails to update a person with missing name',
      build: () => personBloc,
      act: (bloc) => bloc.add(
        UpdatePerson(id: '1', name: '', ssn: '660606'), // Missing name
      ),
      expect: () => [
        PersonLoading(),
        PersonError('Failed to update person: Name is required'),
      ],
      verify: (_) {
        verifyNever(() => personRepository.update(any(), any()));
      },
    );

    blocTest<PersonBloc, PersonState>(
      'fails to update a person with missing SSN',
      build: () => personBloc,
      act: (bloc) => bloc.add(
        UpdatePerson(id: '1', name: 'Updated Name', ssn: ''), // Missing SSN
      ),
      expect: () => [
        PersonLoading(),
        PersonError('Failed to update person: SSN is required'),
      ],
      verify: (_) {
        verifyNever(() => personRepository.update(any(), any()));
      },
    );

    blocTest<PersonBloc, PersonState>(
      'fails to update a person with repository error',
      setUp: () {
        when(() => personRepository.update(any(), any()))
            .thenThrow(Exception('Unexpected error occurred'));
      },
      build: () => personBloc,
      act: (bloc) => bloc.add(
        UpdatePerson(id: '1', name: 'Updated Name', ssn: '660606'),
      ),
      expect: () => [
        PersonLoading(),
        PersonError('Failed to update person: Unexpected error occurred'),
      ],
      verify: (_) {
        verify(() => personRepository.update(any(), any())).called(1);
        verifyNever(() => personRepository.getAll());
      },
    );
  });
}
