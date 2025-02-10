import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Getter for signed-in user as a stream
  Stream<User?> get signedInAuthId => _firebaseAuth.authStateChanges();

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      // Set persistence only for web platforms
      if (kIsWeb) {
        await _firebaseAuth.setPersistence(Persistence.LOCAL);
      }

      // Sign in with email and password
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Log or handle the error
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
    await _firebaseAuth.signOut();
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
