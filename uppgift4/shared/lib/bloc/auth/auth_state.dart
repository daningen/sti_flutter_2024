abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthUnauthenticated extends AuthState {
  final String? errorMessage; // The ? is crucial!
  AuthUnauthenticated({this.errorMessage});
}
