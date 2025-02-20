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

  String?
      _userRole; // Store user role (not currently used, but can be added later)
  String?
      _loggedInUserAuthId; // Store user authId (not currently used, but can be added later)

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

  /// Handles user login.
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

  /// Handles user registration.
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

  /// Handles the creation of a person document in Firestore.
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

  /// Handles listening to authentication state changes.
  Future<void> _onUserSubscriptionRequested(
    AuthFirebaseUserSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('🔄 Fetching user subscription...');

    // Use emit.onEach to listen to the stream of Firebase Auth users.
    return emit.onEach<firebase_auth.User?>(
      authRepository.signedInAuthId, // The stream of Firebase Auth users.
      onData: (authUser) async {
        // Called when a new user authentication state is received.

        if (authUser == null) {
          // No user is signed in.
          emit(AuthUnauthenticated()); // Emit unauthenticated state.
        } else {
          // A user is signed in.

          // Check if the user has a corresponding person document in Firestore.
          final person = await personRepository.getByAuthId(authUser.uid);

          if (person == null) {
            // The user is authenticated with Firebase Auth, but their Person
            // document is missing in Firestore.  This likely means they have
            // registered but not yet completed their profile.
            emit(AuthAuthenticatedNoUser(
              authId: authUser.uid,
              email: authUser.email!,
            ));
          } else {
            // The user is fully authenticated (both Firebase Auth and Firestore).
            _userRole = person.role; // Store user role
            _loggedInUserAuthId = authUser.uid; // Store user authId

            emit(AuthAuthenticated(
              user: authUser,
              person: person,
            )); // Emit authenticated state.
          }
        }
      },
      onError: (error, stackTrace) {
        // Called if an error occurs while listening to the stream.
        emit(AuthFail(
            message: error.toString())); // Emit authentication failure state.
      },
    );
  }

  String? getUserRole() => _userRole; // The getter method
  String? getLoggedInUserAuthId() => _loggedInUserAuthId;

  /// Handles user logout.
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
