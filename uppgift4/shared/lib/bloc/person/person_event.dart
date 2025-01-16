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
  final int id; // Use `id` instead of `personId`
  final String name;
  final String ssn;

  UpdatePerson({
    required this.id, // Match the `id` field name
    required this.name,
    required this.ssn,
  });

  @override
  List<Object?> get props => [id, name, ssn];
}

class DeletePerson extends PersonEvent {
  final int id;

  DeletePerson({required this.id});

  @override
  List<Object?> get props => [id];
}

class SelectPerson extends PersonEvent {
  final Person person;

  SelectPerson({required this.person});

  @override
  List<Object?> get props => [person];
}
