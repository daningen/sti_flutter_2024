import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading()); // Correct: emit() is void

      try {
        final errorMessage = await _authService.login(event.username,
            event.password); // Correct: Await the result of login

        if (errorMessage == null) {
          emit(AuthAuthenticated()); // Correct: emit() is void
        } else {
          emit(AuthUnauthenticated(
              errorMessage: errorMessage)); // Correct: emit() is void
        }
      } catch (e) {
        emit(AuthUnauthenticated(
            errorMessage: e.toString())); // Correct: emit() is void
      }
    });

    on<LogoutRequested>((event, emit) {
      _authService.logout();
      emit(AuthUnauthenticated());
    });
  }
}
