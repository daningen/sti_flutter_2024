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
  final PersonRepository personRepository;

  AuthFirebaseBloc({
    required this.authRepository,
    required this.userRepository,
    required this.personRepository,
  }) : super(AuthInitial()) {
    on<AuthFirebaseLogin>(_onLogin);
    on<AuthFirebaseRegister>(_onRegister);
    on<AuthFirebaseCreatePerson>(_onCreatePerson);
    on<AuthFirebaseUserSubscriptionRequested>(_onUserSubscriptionRequested);
    on<LogoutRequested>(_onLogout);

    // Start listening to authentication changes when the bloc is created.
    add(AuthFirebaseUserSubscriptionRequested());
  }

  void _onLogin(AuthFirebaseLogin event, Emitter<AuthState> emit) async {
    emit(AuthPending()); // Emit loading state

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

      final person = await personRepository.getByAuthId(user.uid);

      if (person == null) {
        debugPrint(
            "🟡 Login successful, but no Person found. Waiting for creation.");
        emit(AuthUnauthenticated(
            errorMessage: "Pending person creation, user=${user.email}"));
        return;
      }

      debugPrint("✅ Login complete. User=${user.email}, Person=${person.name}");
      emit(AuthAuthenticated(
          user: user,
          person: person)); // Emit authenticated state with user and person
    } catch (e) {
      emit(AuthFail(message: "Login failed: ${e.toString()}"));
    }
  }

  Future<void> _onRegister(
    AuthFirebaseRegister event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthPending()); // Emit loading state

    try {
      debugPrint("Processing registration for email: ${event.email}");

      final userCredential = await authRepository.register(
          email: event.email, password: event.password);

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        debugPrint('✅ Registration successful. User UID: ${firebaseUser.uid}');

        emit(AuthAuthenticatedNoUser(
          // User registered but person data missing
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

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        debugPrint(
            '⚠️ Firebase user is null after person creation. User may need to log in again.');
        emit(AuthUnauthenticated(
            errorMessage: 'User session lost. Please log in again.'));
        return;
      }

      // Fetch the person object to emit correct state
      final createdPerson =
          await personRepository.getByAuthId(firebaseUser.uid);

      if (createdPerson != null) {
        emit(AuthAuthenticated(
            user: firebaseUser,
            person:
                createdPerson)); // Emit authenticated state with user and person
      } else {
        emit(AuthFirebaseError('Failed to load user data after creation.'));
      }
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

     
    return emit.onEach<firebase_auth.User?>(
      authRepository.signedInAuthId,  
      onData: (authUser) async {
        if (authUser == null) {
          emit(AuthUnauthenticated());  
        } else {
          // Check if the user has a corresponding person document
          final person = await personRepository.getByAuthId(authUser.uid);

          if (person == null) {
            emit(AuthAuthenticatedNoUser(
              // User exists in Firebase Auth, but not in Firestore
              authId: authUser.uid,
              email: authUser.email!,
            ));
          } else {
            emit(AuthAuthenticated(
                user: authUser, person: person)); // User is fully authenticated
          }
        }
      },
      onError: (error, stackTrace) {
        emit(AuthFail(message: error.toString()));  
      },
    );
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authRepository.logout();
       
    } catch (e) {
      emit(AuthFail(message: e.toString()));
    }
  }
}
