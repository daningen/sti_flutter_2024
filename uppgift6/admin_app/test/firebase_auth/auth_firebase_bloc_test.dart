import 'package:shared/bloc/auth/auth_firebase_bloc.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared/shared.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockPersonRepository extends Mock
    implements PersonRepository {} // ✅ Added

class MockFirebaseUser extends Mock implements firebase_auth.User {}

class UserCredentialFake extends Fake implements firebase_auth.UserCredential {}

void main() {
  group('AuthFirebaseBloc Tests', () {
    late MockAuthRepository mockAuthRepository;
    late MockUserRepository mockUserRepository;
    late MockPersonRepository mockPersonRepository; // ✅ Added mock
    late AuthFirebaseBloc authFirebaseBloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockUserRepository = MockUserRepository();
      mockPersonRepository = MockPersonRepository(); // ✅ Initialize mock

      registerFallbackValue(UserCredentialFake());

      authFirebaseBloc = AuthFirebaseBloc(
        authRepository: mockAuthRepository,
        userRepository: mockUserRepository,
        personRepository: mockPersonRepository, // ✅ Pass mock here
      );
    });

    blocTest<AuthFirebaseBloc, AuthState>(
      'emits [AuthPending, AuthAuthenticated] when login succeeds',
      build: () {
        final mockUser = MockFirebaseUser();
        when(() => mockUser.email).thenReturn('test1@test.com');
        when(() => mockUser.uid).thenReturn('123');

        when(() => mockAuthRepository.login(
            email: 'test1@test.com', password: 'password')).thenAnswer(
          (_) async => UserCredentialFake(),
        );
        when(() => mockAuthRepository.getCurrentUser()).thenReturn(mockUser);

        // ✅ Mock getByAuthId to return a Person
        when(() => mockPersonRepository.getByAuthId('123')).thenAnswer(
          (_) async => Person(
            id: '1',
            authId: '123',
            name: 'Test User',
            ssn: '123456',
          ),
        );

        return authFirebaseBloc;
      },
      act: (bloc) => bloc.add(
          AuthFirebaseLogin(email: 'test1@test.com', password: 'password')),
      expect: () => [
        isA<AuthPending>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthFirebaseBloc, AuthState>(
      'emits [AuthPending, AuthUnauthenticated] when login fails',
      build: () {
        when(() => mockAuthRepository.login(
            email: 'wrong@test.com', password: 'wrong-password')).thenThrow(
          Exception('Login failed'),
        );
        return authFirebaseBloc;
      },
      act: (bloc) => bloc.add(AuthFirebaseLogin(
          email: 'wrong@test.com', password: 'wrong-password')),
      expect: () => [
        isA<AuthPending>(),
        isA<AuthUnauthenticated>(),
      ],
    );
  });
}
