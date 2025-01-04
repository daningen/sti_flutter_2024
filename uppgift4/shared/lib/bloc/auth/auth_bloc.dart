import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/bloc/auth/auth_event.dart';
import 'package:shared/bloc/auth/auth_state.dart';
import 'package:shared/services/auth_service_interface.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthServiceInterface authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Handles the login request event
  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // Transition to loading state
    try {
      await authService.login(event.username, event.password);
      emit(AuthAuthenticated()); // Transition to authenticated state
    } catch (e) {
      final errorMessage =
          e is Exception ? e.toString() : 'Unexpected error occurred.';
      emit(AuthUnauthenticated(errorMessage: errorMessage));
    }
  }

  /// Handles the logout request event
  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    authService.logout();
    emit(AuthUnauthenticated()); // Transition back to unauthenticated state
  }
}
