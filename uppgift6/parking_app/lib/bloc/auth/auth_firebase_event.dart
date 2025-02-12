part of 'auth_firebase_bloc.dart';

abstract class AuthFirebaseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthFirebaseUserSubscriptionRequested extends AuthFirebaseEvent {}

class AuthFirebaseLogin extends AuthFirebaseEvent {
  final String email;
  final String password;

  AuthFirebaseLogin({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthFirebaseEvent {}

class AuthFirebaseRegister extends AuthFirebaseEvent {
  final String email;
  final String password;

  AuthFirebaseRegister({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthFirebaseCreatePerson extends AuthFirebaseEvent {
  final String authId;
  final String name;
  final String ssn;

  AuthFirebaseCreatePerson(
      {required this.authId, required this.name, required this.ssn});
}
