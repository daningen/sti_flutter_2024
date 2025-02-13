import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';

part 'auth_firebase_state.dart';
part 'auth_firebase_event.dart';

class AuthFirebaseBloc extends Bloc<AuthFirebaseEvent, AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final PersonRepository personRepository; // ✅ Added PersonRepository

  AuthFirebaseBloc({
    required this.authRepository,
    required this.userRepository,
    required this.personRepository, // ✅ Initialize PersonRepository
  }) : super(AuthInitial()) {
    on<AuthFirebaseLogin>(_onLogin);
    on<AuthFirebaseRegister>(_onRegister);
    on<AuthFirebaseCreatePerson>(_onCreatePerson);
    on<AuthFirebaseUserSubscriptionRequested>(_onUserSubscriptionRequested);
    on<LogoutRequested>(_onLogout);
  }

  void _onLogin(AuthFirebaseLogin event, Emitter<AuthState> emit) async {
    emit(AuthPending());

    try {
      final userCredential = await authRepository.login(
        email: event.email,
        password: event.password,
      );

      final user = userCredential.user;
      if (user == null) {
        emit(AuthFail(message: "Login failed: No user found"));
        return;
      }

      // 🔍 Fetch associated person data
      final person = await personRepository.getByAuthId(user.uid); // ✅ Fix: Use personRepository

      if (person == null) {
        debugPrint("🟡 Login successful, but no Person found. Waiting for creation.");
        emit(AuthUnauthenticated(
            errorMessage: "Pending person creation, user=${user.email}"));
        return;
      }

      // ✅ User and person exist, mark as fully authenticated
      debugPrint("✅ Login complete. User=${user.email}, Person=${person.name}");
      emit(AuthAuthenticated(user: user)); // 🔥 Mark as authenticated
    } catch (e) {
      emit(AuthFail(message: "Login failed: ${e.toString()}"));
    }
  }

  Future<void> _onRegister(
    AuthFirebaseRegister event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthPending());
    try {
      debugPrint("Processing registration for email: ${event.email}");

      final userCredential = await authRepository.register(
          email: event.email, password: event.password);

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        debugPrint('✅ Registration successful. User UID: ${firebaseUser.uid}');

        emit(AuthAuthenticatedNoUser(
          authId: firebaseUser.uid,
          email: firebaseUser.email!,
        ));
      } else {
        debugPrint('❌ Registration failed.');
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
      final person = Person(
        id: const Uuid().v4(),
        authId: event.authId,
        name: event.name,
        ssn: event.ssn,
      );

      await FirebaseFirestore.instance
          .collection('persons')
          .doc(person.id)
          .set(person.toJson());

      debugPrint('✅ Person created successfully');

      // ✅ Fetch user from Firebase Authentication
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        debugPrint(
            '⚠️ Firebase user is null after person creation. User may need to log in again.');
        emit(AuthUnauthenticated(
            errorMessage: 'User session lost. Please log in again.'));
        return;
      }

      // ✅ Now update state to authenticated
      emit(AuthAuthenticated(user: firebaseUser));
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
