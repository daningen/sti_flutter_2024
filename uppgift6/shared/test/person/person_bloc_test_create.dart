// import 'package:firebase_repositories/firebase_repositories.dart';
// import 'package:shared/bloc/person/person_bloc.dart';
// import 'package:shared/bloc/person/person_event.dart';
// import 'package:shared/bloc/person/person_state.dart';

// import 'package:bloc_test/bloc_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:shared/shared.dart';
// import 'package:test/test.dart';

// class MockPersonRepository extends Mock implements PersonRepository {}

// void main() {
//   group('PersonBloc - CreatePerson', () {
//     late MockPersonRepository personRepository;
//     late PersonBloc personBloc;

//     setUp(() {
//       personRepository = MockPersonRepository();
//       personBloc = PersonBloc(personRepository: personRepository);
//       registerFallbackValue(Person(
//         id: '', // Ensure fallback has an `id` if required
//         name: 'Fallback',
//         ssn: '720606',
//       ));
//     });

//     tearDown(() {
//       personBloc.close();
//     });

//     blocTest<PersonBloc, PersonState>(
//       'creates a person and reloads persons',
//       setUp: () {
//         when(() => personRepository.create(any())).thenAnswer(
//           (_) async => Person(id: '1', name: 'Dan Erlandsson', ssn: '820202'),
//         );
//         when(() => personRepository.getAll()).thenAnswer(
//           (_) async => [
//             Person(id: '1', name: 'Dan Erlandsson', ssn: '820202'),
//           ],
//         );
//       },
//       build: () => personBloc,
//       act: (bloc) =>
//           bloc.add(CreatePerson(name: 'Dan Erlandsson', ssn: '820202')),
//       expect: () => [
//         PersonLoading(),
//         isA<PersonLoaded>(),
//       ],
//       verify: (_) {
//         verify(() => personRepository.create(any())).called(1);
//         verify(() => personRepository.getAll()).called(1);
//       },
//     );
//   });
// }
