// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shared/bloc/auth/auth_bloc.dart';
// import 'package:shared/bloc/auth/auth_state.dart';

// class StartView extends StatelessWidget {
//   const StartView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Welcome'),
//       ),
//       body: BlocListener<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is AuthAuthenticated) {
//             debugPrint('✅ User authenticated, navigating to /start/home');
//             context.go('/start/home'); // ✅ Correct redirect
//           }
//         },
//         child: BlocBuilder<AuthBloc, AuthState>(
//           builder: (context, state) {
//             if (state is AuthLoading) {
//               return const Center(child: CircularProgressIndicator());
//             } else {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Hello, please login or register:',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 24),
//                     ElevatedButton(
//                       onPressed: () {
//                         debugPrint('Navigating to login page...');
//                         context.go('/login');
//                       },
//                       child: const Text('Login'),
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         debugPrint('Navigating to register page...');
//                         context.go('/register');
//                       },
//                       child: const Text('Create Account'),
//                     ),
//                   ],
//                 ),
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
