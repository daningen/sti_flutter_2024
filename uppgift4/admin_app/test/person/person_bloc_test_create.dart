import 'package:admin_app/bloc/person/person_bloc.dart';
import 'package:admin_app/bloc/person/person_event.dart';
import 'package:admin_app/bloc/person/person_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';

class MockPersonRepository extends Mock implements PersonRepository {}

void main() {
  group('PersonBloc - CreatePerson', () {
    late MockPersonRepository personRepository;
    late PersonBloc personBloc;

    setUp(() {
      personRepository = MockPersonRepository();
      personBloc = PersonBloc(personRepository: personRepository);
      registerFallbackValue(
          Person(name: 'Fallback', ssn: '720606')); // Register fallback
    });

    blocTest<PersonBloc, PersonState>(
      'creates a person and reloads persons',
      setUp: () {
        when(() => personRepository.create(any())).thenAnswer(
          (_) async => Person(name: 'Dan Erlandsson', ssn: '820202'),
        );
        when(() => personRepository.getAll()).thenAnswer(
          (_) async => [Person(name: 'Dan Erlandsson', ssn: '820202')],
        );
      },
      build: () => personBloc,
      act: (bloc) =>
          bloc.add(CreatePerson(name: 'Dan Erlandsson', ssn: '820202')),
      expect: () => [
        PersonLoading(),
        isA<PersonLoaded>(),
      ],
      verify: (_) {
        verify(() => personRepository.create(any())).called(1);
        verify(() => personRepository.getAll()).called(1);
      },
    );
  });
}
