import 'package:admin_app/firebase_options.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  group('Firebase Authentication Integration Test', () {
    setUpAll(() async {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    });

    test('Login succeeds with valid credentials', () async {
      final FirebaseAuth auth = FirebaseAuth.instance;

      try {
        final UserCredential userCredential =
            await auth.signInWithEmailAndPassword(
          email: 'test1@test.com', // Replace with a valid test user
          password: 'password',
        );

        expect(userCredential.user, isNotNull);
        expect(userCredential.user!.email, equals('test1@test.com'));
      } catch (e) {
        fail('Login failed with error: $e');
      }
    });

    test('Login fails with invalid credentials', () async {
      final FirebaseAuth auth = FirebaseAuth.instance;

      try {
        await auth.signInWithEmailAndPassword(
          email: 'wrong@test.com',
          password: 'wrong-password',
        );
        fail('Expected an exception, but login succeeded.');
      } catch (e) {
        expect(e, isA<FirebaseAuthException>());
        final error = e as FirebaseAuthException;
        expect(error.code, equals('user-not-found'));
      }
    });
  });
}
