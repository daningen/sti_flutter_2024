// import 'package:firebase_repositories/firebase_repositories.dart';
// import 'package:shared/bloc/person/person_bloc.dart';
// import 'package:shared/bloc/person/person_event.dart';
// import 'package:shared/bloc/person/person_state.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:bloc_test/bloc_test.dart';
// import 'package:mocktail/mocktail.dart';

// import 'package:shared/shared.dart';

// class MockPersonRepository extends Mock implements PersonRepository {}

// void main() {
//   group('PersonBloc - DeletePerson', () {
//     late MockPersonRepository personRepository;
//     late PersonBloc personBloc;

//     setUp(() {
//       personRepository = MockPersonRepository();
//       personBloc = PersonBloc(personRepository: personRepository);
//       registerFallbackValue(
//         Person(id: 'fallback-id', name: 'Fallback Person', ssn: '000000'),
//       );
//     });

//     blocTest<PersonBloc, PersonState>(
//       'deletes a person and reloads persons',
//       setUp: () {
//         // Mock the delete method to return void
//         when(() => personRepository.delete(any()))
//             .thenAnswer((_) async => null);

//         // Mock the getAll method to return an empty list after deletion
//         when(() => personRepository.getAll()).thenAnswer((_) async => []);
//       },
//       build: () => personBloc,
//       act: (bloc) => bloc.add(DeletePerson(id: '1')), // Using string ID
//       expect: () => [
//         PersonLoading(),
//         isA<PersonLoaded>(),
//       ],
//       verify: (_) {
//         verify(() => personRepository.delete('1')).called(1);
//         verify(() => personRepository.getAll()).called(1);
//       },
//     );
//   });
// }
