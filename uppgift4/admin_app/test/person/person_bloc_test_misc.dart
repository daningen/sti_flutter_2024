import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';
import 'package:shared/bloc/person/person_bloc.dart';
import 'package:shared/bloc/person/person_event.dart';
import 'package:shared/bloc/person/person_state.dart';

class MockPersonRepository extends Mock implements PersonRepository {}

class FakePerson extends Fake implements Person {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakePerson());
  });

  group('PersonBloc - Create and Load Tests', () {
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
      'creates a person and reloads persons',
      setUp: () {
        when(() => personRepository.create(any())).thenAnswer(
          (_) async => Person(name: 'Dan Erlandsson', ssn: '920202', id: 1),
        );
        when(() => personRepository.getAll()).thenAnswer((_) async => [
              Person(name: 'Dan Erlandsson', ssn: '920202', id: 1),
            ]);
      },
      build: () => personBloc,
      act: (bloc) => bloc.add(
        CreatePerson(name: 'Dan Erlandsson', ssn: '920202'),
      ),
      expect: () => [
        PersonLoading(),
        isA<PersonLoaded>(),
      ],
      verify: (_) {
        verify(() => personRepository.create(any())).called(1);
        verify(() => personRepository.getAll()).called(1);
      },
    );

    blocTest<PersonBloc, PersonState>(
      'fails to create a person with missing name',
      build: () => personBloc,
      act: (bloc) => bloc.add(
        CreatePerson(name: '', ssn: '920202'), // Missing name
      ),
      expect: () => [
        PersonError('Failed to create person: Name is required'),
      ],
      verify: (_) {
        verifyNever(() => personRepository.create(any()));
      },
    );

    blocTest<PersonBloc, PersonState>(
      'fails to create a person with missing SSN',
      build: () => personBloc,
      act: (bloc) => bloc.add(
        CreatePerson(name: 'Dan Erlandsson', ssn: ''), // Missing SSN
      ),
      expect: () => [
        PersonError('Failed to create person: SSN is required'),
      ],
      verify: (_) {
        verifyNever(() => personRepository.create(any()));
      },
    );

    blocTest<PersonBloc, PersonState>(
      'returns an empty list when no persons exist',
      setUp: () {
        when(() => personRepository.getAll()).thenAnswer((_) async => []);
      },
      build: () => personBloc,
      act: (bloc) => bloc.add(LoadPersons()),
      expect: () => [
        PersonLoading(),
        PersonLoaded(persons: const []),
      ],
      verify: (_) {
        verify(() => personRepository.getAll()).called(1);
      },
    );

    blocTest<PersonBloc, PersonState>(
      'fails to create a duplicate person',
      setUp: () {
        when(() => personRepository.create(any()))
            .thenThrow(Exception('Duplicate SSN detected'));
      },
      build: () => personBloc,
      act: (bloc) => bloc.add(
        CreatePerson(name: 'Dan Erlandsson', ssn: '920202'),
      ),
      expect: () => [
        isA<PersonError>().having(
          (error) => error.message,
          'message',
          'Failed to create person: Exception: Duplicate SSN detected',
        ),
      ],
      verify: (_) {
        verify(() => personRepository.create(any())).called(1);
      },
    );
  });
}
