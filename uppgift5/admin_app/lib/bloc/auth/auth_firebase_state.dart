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

  AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  final String? errorMessage;

  AuthUnauthenticated({this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
