part of 'auth_firebase_bloc.dart';

/// Base class for all authentication states.
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// The initial state when the authentication process has not started.
class AuthInitial extends AuthState {
  @override
  String toString() => 'AuthInitial';
}

/// The state when an authentication operation (login or logout) is in progress.
class AuthPending extends AuthState {
  @override
  String toString() => 'AuthPending';
}

/// The state when an authentication attempt fails.
class AuthFail extends AuthState {
  final String message;

  /// Constructor to capture the error message from the failure.
  AuthFail({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'AuthFail: $message';
}

/// The state when the user is successfully authenticated.
class AuthAuthenticated extends AuthState {
  final firebase_auth.User user;

  /// Constructor to store the authenticated user details.
  AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];

  @override
  String toString() => 'AuthAuthenticated: ${user.email}';
}

class AuthUnauthenticated extends AuthState {
  final firebase_auth.User? user; // ✅ Store user data
  final String? errorMessage;

  AuthUnauthenticated({this.user, this.errorMessage});

  @override
  List<Object?> get props => [user, errorMessage];

  @override
  String toString() =>
      'AuthUnauthenticated: ${errorMessage ?? "No error message"}, user=${user?.email ?? "null"}';
}

class AuthFirebasePersonCreated extends AuthState {}

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

  @override
  String toString() => 'AuthAuthenticatedNoUser: $email';
}
