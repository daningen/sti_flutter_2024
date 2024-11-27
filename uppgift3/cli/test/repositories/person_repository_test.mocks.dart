import 'package:cli/repositories/person_repository.dart';

class PersonOperations {
  final PersonRepository repository;

  PersonOperations(this.repository);

  Future create() async {
    // Use `repository.create()` directly
  }
}
