import 'package:shared/bloc/person/person_bloc.dart';
import 'package:shared/bloc/person/person_event.dart';
import 'package:shared/bloc/person/person_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';

class MockPersonRepository extends Mock implements PersonRepository {}

void main() {
  group('PersonBloc - UpdatePerson', () {
    late MockPersonRepository personRepository;
    late PersonBloc personBloc;

    setUp(() {
      personRepository = MockPersonRepository();
      personBloc = PersonBloc(personRepository: personRepository);
      registerFallbackValue(Person(name: 'Fallback', ssn: '720606'));
    });

    blocTest<PersonBloc, PersonState>(
      'updates a person and reloads persons',
      setUp: () {
        when(() => personRepository.update(any(), any())).thenAnswer(
          (_) async => Person(name: 'Updated Name', ssn: '660606', id: 1),
        );
        when(() => personRepository.getAll()).thenAnswer(
          (_) async => [Person(name: 'Updated Name', ssn: '660606', id: 1)],
        );
      },
      build: () => personBloc,
      act: (bloc) => bloc.add(
        UpdatePerson(id: 1, name: 'Updated Name', ssn: '660606'),
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
  });
}
