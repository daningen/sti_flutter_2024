import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

part 'auth_firebase_state.dart';
part 'auth_firebase_event.dart';

class AuthFirebaseBloc extends Bloc<AuthFirebaseEvent, AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  AuthFirebaseBloc({required this.authRepository, required this.userRepository})
      : super(AuthInitial()) {
    on<AuthFirebaseLogin>(_onLogin);
    on<AuthFirebaseRegister>(_onRegister);
    on<AuthFirebaseCreatePerson>(_onCreatePerson);
    on<AuthFirebaseUserSubscriptionRequested>(_onUserSubscriptionRequested);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(
    AuthFirebaseLogin event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthPending());
    try {
      debugPrint("Processing login for email: ${event.email}");

      await authRepository.login(email: event.email, password: event.password);
      final firebase_auth.User? user = authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthFail(message: 'User not found.'));
      }
    } catch (e) {
      debugPrint("Login error: $e");
      emit(AuthFail(message: e.toString()));
    }
  }

  Future<void> _onRegister(
    AuthFirebaseRegister event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthPending());
    try {
      debugPrint("Processing registration for email: ${event.email}");

      await authRepository.register(
          email: event.email, password: event.password);
      final user = authRepository.getCurrentUser();

      if (user != null && user.uid.isNotEmpty && user.email != null) {
        debugPrint('✅ Registration successful, waiting for person info');

        emit(AuthAuthenticatedNoUser(
          authId: user.uid,
          email: user.email!,
        ));
      } else {
        debugPrint('❌ User registration failed or email is null');
        emit(AuthUnauthenticated(errorMessage: 'Registration failed.'));
      }
    } catch (e) {
      debugPrint("❌ Registration error: $e");
      emit(AuthUnauthenticated(errorMessage: e.toString()));
    }
  }

  void _onCreatePerson(
      AuthFirebaseCreatePerson event, Emitter<AuthState> emit) async {
    debugPrint('🆕 Creating person in Firestore: ${event.name}, ${event.ssn}');

    try {
      final person = Person(id: event.authId, name: event.name, ssn: event.ssn);

      await FirebaseFirestore.instance
          .collection('persons')
          .doc(event.authId)
          .set(person.toJson());

      debugPrint('✅ Person created successfully');

      // Mark the user as fully authenticated
      final user = authRepository.getCurrentUser();
      emit(AuthAuthenticated(user: user!));
    } catch (e) {
      debugPrint('❌ Error creating person: $e');
      emit(AuthFirebaseError('Failed to create person'));
    }
  }

  Future<void> _onUserSubscriptionRequested(
    AuthFirebaseUserSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('🔄 Fetching user subscription...');
    // Implement logic for handling subscription if needed
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
