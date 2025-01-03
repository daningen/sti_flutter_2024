import 'package:flutter_bloc/flutter_bloc.dart'; // Ensure this import exists
import 'package:shared/bloc/auth/auth_event.dart';
import 'package:shared/bloc/auth/auth_state.dart';
import 'package:shared/services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // Transition to loading state
    try {
      await authService.login(event.username, event.password);
      emit(AuthAuthenticated()); // Transition to authenticated state
    } catch (e) {
      // Log the error and emit an unauthenticated state with the error message
      final errorMessage = e is Exception ? e.toString() : 'Unexpected error';
      emit(AuthUnauthenticated(errorMessage: errorMessage));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    authService.logout();
    emit(AuthUnauthenticated()); // Transition to unauthenticated state
  }
}
