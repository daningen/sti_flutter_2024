import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/bloc/auth/auth_firebase_bloc.dart' as local;

import '../utils/validators.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<local.AuthFirebaseBloc>();

    final formKey = GlobalKey<FormState>();
    final emailController =
        TextEditingController(text: 'test@test.com'); // Prefilled email
    final passwordController =
        TextEditingController(text: 'password'); // Prefilled password

    return BlocListener<local.AuthFirebaseBloc, local.AuthState>(
      listener: (context, state) {
        if (state is local.AuthAuthenticated) {
          debugPrint('✅ Auth successful: ${state.user.email}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Login successful! Welcome, ${state.user.email}"),
              backgroundColor: Colors.green,
            ),
          );

          context.go('/start'); // ✅ Navigate to start page
        } else if (state is local.AuthUnauthenticated) {
          debugPrint('⚠️ AuthUnauthenticated: ${state.errorMessage}');

          // ✅ Handle "Pending person creation" case
          if (state.errorMessage?.contains('Pending person creation') ??
              false) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('No Person Found'),
                content: const Text(
                    'No person exists for this account. Would you like to register a new person?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Stay on Login'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/register'); // ✅ Go to Register View
                    },
                    child: const Text('Register Person'),
                  ),
                ],
              ),
            );
          }
        } else if (state is local.AuthFail) {
          debugPrint('❌ Auth failed: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Authentication failed: ${state.message}"),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is local.AuthPending) {
          debugPrint('⏳ Authenticating...');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Authenticating... Please wait."),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          debugPrint('⚠️ Unexpected state: $state');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: Form(
              key: formKey,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<local.AuthFirebaseBloc, local.AuthState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            ElevatedButton(
                              onPressed: state is local.AuthPending
                                  ? null
                                  : () {
                                      if (formKey.currentState!.validate()) {
                                        final email =
                                            emailController.text.trim();
                                        final password =
                                            passwordController.text.trim();

                                        authBloc.add(
                                          local.AuthFirebaseLogin(
                                            email: email,
                                            password: password,
                                          ),
                                        );
                                      }
                                    },
                              child: state is local.AuthPending
                                  ? const CircularProgressIndicator()
                                  : const Text('Login'),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                debugPrint(
                                    'Navigating to RegisterView...from loginView');
                                context.push(
                                    '/register'); // Navigate to RegisterView
                              },
                              child:
                                  const Text('Don’t have an account? Register'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
