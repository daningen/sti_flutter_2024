part of 'auth_firebase_bloc.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthPending extends AuthState {}

class AuthFail extends AuthState {
  final String message;
  AuthFail({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticated extends AuthState {
  final firebase_auth.User user;
  final Person person;  

  AuthAuthenticated({required this.user, required this.person}); // Update constructor

  @override
  List<Object?> get props => [user, person]; // Update props

  @override
  String toString() => 'AuthAuthenticated: ${user.email}, Person: ${person.name}'; // Good for debugging
}

class AuthUnauthenticated extends AuthState {
  final firebase_auth.User? user;
  final String? errorMessage;

  AuthUnauthenticated({this.user, this.errorMessage});

  @override
  List<Object?> get props => [user, errorMessage];

  @override
  String toString() =>
      'AuthUnauthenticated: ${errorMessage ?? "No error message"}, user=${user?.email ?? "null"}';
}

class AuthFirebasePersonCreated extends AuthState {} // todo not used?

class AuthFirebaseError extends AuthState {
  final String message;
  AuthFirebaseError(this.message);
}

class AuthAuthenticatedNoUser extends AuthState {
  final String authId;
  final String email;

  AuthAuthenticatedNoUser({required this.authId, required this.email});

  @override
  List<Object?> get props => [authId, email];
}