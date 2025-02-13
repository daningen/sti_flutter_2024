// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared/bloc/auth/old_auth_event.dart';
// import 'package:shared/bloc/auth/old_auth_state.dart';
// import 'package:shared/services/auth_service_interface.dart';

// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final AuthServiceInterface authService;

//   AuthBloc({required this.authService}) : super(AuthInitial()) {
//     on<LoginRequested>(_onLoginRequested);
//     on<LogoutRequested>(_onLogoutRequested);
//   }

//   /// Handles the login request event
//   Future<void> _onLoginRequested(
//       LoginRequested event, Emitter<AuthState> emit) async {
//     debugPrint("[autbloc]: login");
//     emit(AuthLoading()); // Transition to loading state
//     try {
//       await authService.login(event.username, event.password);
//       debugPrint('Login successful. '); //User: ${user.username}');
//       emit(AuthAuthenticated(username: event.username));
//     } catch (e) {
//       final errorMessage =
//           e is Exception ? e.toString() : 'Unexpected error occurred.';
//       emit(AuthUnauthenticated(errorMessage: errorMessage));
//       debugPrint('Login NOT successful. ');
//     }
//   }

//   /// Handles the logout request event
//   void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
//     authService.logout();
//     emit(AuthUnauthenticated()); // Transition back to unauthenticated state
//   }
// }
