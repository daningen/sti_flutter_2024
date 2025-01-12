import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

abstract class PersonState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PersonInitial extends PersonState {}

class PersonLoading extends PersonState {}

class PersonLoaded extends PersonState {
  final List<Person> persons;

  PersonLoaded(this.persons);

  @override
  List<Object?> get props => [persons];
}

class PersonError extends PersonState {
  final String message;

  PersonError(this.message);

  @override
  List<Object?> get props => [message];
}
