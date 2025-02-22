import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Provides a stream of Firebase Auth user objects.
  /// This stream emits a User object whenever the authentication state changes
  /// (e.g., user logs in, logs out, or the authentication state is initialized).
  /// It emits `null` if the user is not authenticated.
  Stream<User?> get signedInAuthId => _firebaseAuth.authStateChanges();

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      // Set persistence only for web platforms.
      if (kIsWeb) {
        await _firebaseAuth.setPersistence(Persistence.LOCAL);
      }

      // Sign in with email and password using Firebase Auth.
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint("Login error: $e");

      rethrow;
    }
  }

  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    // Sign out the current user using Firebase Auth.
    await _firebaseAuth.signOut();
  }

  /// Gets the currently signed-in user.

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
