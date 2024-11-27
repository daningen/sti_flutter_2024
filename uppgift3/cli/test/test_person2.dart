// import 'package:cli_shared/cli_shared.dart';
// import 'package:test/test.dart';
// import 'package:cli/cli_operations/person_operations.dart';
// import 'mock_person_repository.dart';
// import 'test_helpers.dart';

// void main() {
//   group('PersonOperations Unit Tests', () {
//     late MockPersonRepository mockRepository;

//     setUp(() {
//       mockRepository = MockPersonRepository();
//     });

//     test('Create person with valid input', () async {
//       final person = Person(name: 'Dan Er', ssn: '720606');
//       await PersonOperations.create(person: person, repository: mockRepository);

//       final createdPerson = await mockRepository.getById(person.id);
//       expect(createdPerson.name, 'Eva Berglund');
//       expect(createdPerson.ssn, '720606');
//     });

//     test('Update person information', () async {
//       final person = Person(name: 'Dante S', ssn: '690101');
//       final createdPerson = await mockRepository.create(person);

//       createdPerson.name = 'Hanna Meyer';
//       await PersonOperations.update(
//           person: createdPerson, repository: mockRepository);

//       final updatedPerson = await mockRepository.getById(createdPerson.id);
//       expect(updatedPerson.name, 'Hanna Meyer');
//     });

//     test('Delete a person', () async {
//       final person = Person(name: 'Alice', ssn: '010203');
//       final createdPerson = await mockRepository.create(person);

//       await PersonOperations.delete(
//           personId: createdPerson.id, repository: mockRepository);

//       final deletedPerson = await mockRepository.getById(createdPerson.id);
//       expect(deletedPerson.name, 'Unknown');
//     });
//   });
// }
