// import 'dart:io';

// import 'package:cli/globals.dart';
// import 'package:cli/models/person.dart';
// import 'package:cli/utils/ssn_validator.dart';

// Future<void> showPersons() async {
//   // Await the result from the async method
//   List<Person> allPersons = await personRepository.getAllPeople();

//   if (allPersons.isEmpty) {
//     print("Inga personer registrerade.");
//   } else {
//     print("Lista över alla personer:");
//     for (Person person in allPersons) {
//       print("Namn: ${person.name}, Personnummer: ${person.ssn}");
//     }
//   }
// }

// Future<void> updatePerson() async {
//   print("Ange personnummer för personen du vill uppdatera:");
//   String ssn = stdin.readLineSync()!;

//   // Await the result from the async method
//   Person? personToUpdate =
//       await personRepository.getPersonBySecurityNumber(ssn);

//   if (personToUpdate != null) {
//     print("Ange nytt namn:");
//     String newName = stdin.readLineSync()!;
//     try {
//       // Use the person's id for the update
//       await personRepository.updatePerson(
//           personToUpdate.id,
//           Person(
//               id: personToUpdate.id, name: newName, ssn: personToUpdate.ssn));
//       print("Personen uppdaterad!");
//     } catch (e) {
//       print("Ett fel uppstod vid uppdateringen: $e");
//     }
//   } else {
//     print("Personen med personnummer '$ssn' hittades inte.");
//   }
// }

// Future<void> deletePerson() async {
//   print("Ange personnummer för personen du vill ta bort:");
//   String ssn = stdin.readLineSync()!;

//   // Await the result from the async method
//   Person? personToDelete =
//       await personRepository.getPersonBySecurityNumber(ssn);

//   if (personToDelete != null) {
//     // Await the deletion process
//     await personRepository
//         .deletePersonById(personToDelete.id); // Use deletePersonById
//     print("Person '${personToDelete.name}' borttagen.");
//   } else {
//     print("Personen kunde inte hittas.");
//   }
// }
