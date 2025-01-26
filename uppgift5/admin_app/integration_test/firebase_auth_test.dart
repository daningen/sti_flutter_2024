import 'package:admin_app/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  group('Firebase Authentication Integration Test', () {
    setUpAll(() async {
      // Initialize Firebase
      if (kDebugMode) {
        print('Starting Firebase initialization...');
      }
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (kDebugMode) {
        print('Firebase initialized.');
      }
    });

    test(
      'Login succeeds with valid credentials',
      () async {
        final FirebaseAuth auth = FirebaseAuth.instance;

        if (kDebugMode) {
          print('Attempting login with valid credentials...');
        }
        try {
          final UserCredential userCredential =
              await auth.signInWithEmailAndPassword(
            email: 'test1@test.com', // Replace with a valid test user
            password: 'password',
          );

          if (kDebugMode) {
            print('Login successful!');
          }
          expect(userCredential.user, isNotNull);
          expect(userCredential.user!.email, equals('test1@test.com'));
        } catch (e) {
          fail('Login failed with error: $e');
        }
      },
      timeout: Timeout(Duration(minutes: 2)),
    );

    test(
      'Login fails with invalid credentials',
      () async {
        final FirebaseAuth auth = FirebaseAuth.instance;

        if (kDebugMode) {
          print('Attempting login with invalid credentials...');
        }
        try {
          await auth.signInWithEmailAndPassword(
            email: 'wrong@test.com',
            password: 'wrong-password',
          );
          fail('Expected an exception, but login succeeded.');
        } catch (e) {
          expect(e, isA<FirebaseAuthException>());
          final error = e as FirebaseAuthException;

          if (kDebugMode) {
            print('Login failed as expected. Error: ${error.code}');
          }
          // Check for either 'user-not-found' or 'wrong-password' based on Firebase behavior
          expect(
            ['user-not-found', 'wrong-password'].contains(error.code),
            isTrue,
          );
        }
      },
      timeout: Timeout(Duration(minutes: 2)),
    );
  });
}
