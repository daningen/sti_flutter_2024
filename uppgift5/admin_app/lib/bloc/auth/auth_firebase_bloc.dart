import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';

part 'auth_firebase_state.dart';
part 'auth_firebase_event.dart';

class AuthFirebaseBloc extends Bloc<AuthFirebaseEvent, AuthState> {
  final AuthRepository authRepository;

  AuthFirebaseBloc(
      {required this.authRepository, required UserRepository userRepository})
      : super(AuthInitial()) {
    on<AuthFirebaseLogin>(_onLogin);
    on<AuthFirebaseUserSubscriptionRequested>(_onUserSubscriptionRequested);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(
    AuthFirebaseLogin event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthPending());
    try {
      // Debug: Print the credentials being processed
      debugPrint(
          "Processing login for email: ${event.email} and password: ${event.password}");

      await authRepository.login(email: event.email, password: event.password);
      final user = authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated(errorMessage: 'User not found.'));
      }
    } catch (e) {
      debugPrint("Login error: $e"); // Debug: Print the error
      emit(AuthUnauthenticated(errorMessage: e.toString()));
    }
  }

  Future<void> _onUserSubscriptionRequested(
    AuthFirebaseUserSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Implement subscription logic here
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authRepository.logout();
      emit(AuthUnauthenticated(errorMessage: 'Your error message'));
    } catch (e) {
      emit(AuthFail(message: e.toString()));
    }
  }
}
