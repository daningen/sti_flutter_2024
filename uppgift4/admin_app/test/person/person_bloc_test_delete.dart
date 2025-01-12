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
  group('PersonBloc - DeletePerson', () {
    late MockPersonRepository personRepository;
    late PersonBloc personBloc;

    setUp(() {
      personRepository = MockPersonRepository();
      personBloc = PersonBloc(personRepository: personRepository);
    });

    blocTest<PersonBloc, PersonState>(
      'deletes a person and reloads persons',
      setUp: () {
        when(() => personRepository.delete(any())).thenAnswer(
          (_) async => Person(name: 'Deleted Person', ssn: '720202', id: 1),
        );
        when(() => personRepository.getAll()).thenAnswer((_) async => []);
      },
      build: () => personBloc,
      act: (bloc) => bloc.add(DeletePerson(id: 1)),
      expect: () => [
        PersonLoading(),
        isA<PersonLoaded>(),
      ],
      verify: (_) {
        verify(() => personRepository.delete(any())).called(1);
        verify(() => personRepository.getAll()).called(1);
      },
    );
  });
}
