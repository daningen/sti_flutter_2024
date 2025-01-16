abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {
  final String? errorMessage;
  AuthUnauthenticated({this.errorMessage});
}

class AuthAuthenticated extends AuthState {
  final String username;

  AuthAuthenticated({required this.username});
}
