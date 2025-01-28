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
    on<AuthFirebaseRegister>(_onRegister); // Add register handler
    on<AuthFirebaseUserSubscriptionRequested>(_onUserSubscriptionRequested);
    on<LogoutRequested>(_onLogout);
  }

  // Future<void> _onLogin(
  //   AuthFirebaseLogin event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthPending());
  //   try {
  //     debugPrint(
  //         "Processing login for email: ${event.email} and password: ${event.password}");

  //     await authRepository.login(email: event.email, password: event.password);
  //     final user = authRepository.getCurrentUser();
  //     if (user != null) {
  //       emit(AuthAuthenticated(user: user));
  //     } else {
  //       emit(AuthUnauthenticated(errorMessage: 'User not found.'));
  //     }
  //   } catch (e) {
  //     if (e is firebase_auth.FirebaseAuthException &&
  //         e.code == 'keychain-error') {
  //       debugPrint(
  //           "Keychain error detected. Please ensure Keychain access is properly configured.");
  //     }
  //     debugPrint("Login error: $e");
  //     emit(AuthUnauthenticated(errorMessage: e.toString()));
  //   }
  // }

  Future<void> _onLogin(
    AuthFirebaseLogin event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthPending());
    try {
      debugPrint(
          "Processing login for email: ${event.email} and password: ${event.password}");

      await authRepository.login(email: event.email, password: event.password);
      final user = authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthFail(message: 'User not found.'));
      }
    } catch (e) {
      if (e is firebase_auth.FirebaseAuthException &&
          e.code == 'keychain-error') {
        debugPrint(
            "Keychain error detected. Please ensure Keychain access is properly configured.");
      }
      debugPrint("Login error: $e"); // Log the detailed error
      emit(AuthFail(message: e.toString())); // Emit AuthFail here
    }
  }

  Future<void> _onRegister(
    AuthFirebaseRegister event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthPending());
    try {
      debugPrint(
          "Processing registration for email: ${event.email} and password: ${event.password}");

      await authRepository.register(
          email: event.email, password: event.password);
      final user = authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated(errorMessage: 'Registration failed.'));
      }
    } catch (e) {
      debugPrint("Registration error: $e");
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
      emit(AuthUnauthenticated(errorMessage: 'Logged out successfully.'));
    } catch (e) {
      emit(AuthFail(message: e.toString()));
    }
  }
}
