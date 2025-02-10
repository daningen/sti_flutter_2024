import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

abstract class PersonEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPersons extends PersonEvent {}

class ReloadPersons extends PersonEvent {}

class CreatePerson extends PersonEvent {
  final String name;
  final String ssn;

  CreatePerson({required this.name, required this.ssn});

  @override
  List<Object?> get props => [name, ssn];
}

class UpdatePerson extends PersonEvent {
  final String id; // Changed from `int` to `String`
  final String name;
  final String ssn;

  UpdatePerson({
    required this.id, // Updated type
    required this.name,
    required this.ssn,
  });

  @override
  List<Object?> get props => [id, name, ssn];
}

class DeletePerson extends PersonEvent {
  final String id; // Changed from `int` to `String`

  DeletePerson({required this.id}); // Updated type

  @override
  List<Object?> get props => [id];
}

class SelectPerson extends PersonEvent {
  final Person person;

  SelectPerson({required this.person});

  @override
  List<Object?> get props => [person];
}
