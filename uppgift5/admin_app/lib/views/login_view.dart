import 'package:admin_app/bloc/auth/auth_firebase_bloc.dart' as local;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: unused_import
import 'package:go_router/go_router.dart';

import '../utils/validators.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<local.AuthFirebaseBloc>();

    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController(text: 'test@test.com'); // Prefilled email
    final passwordController = TextEditingController(text: 'password'); // Prefilled password

    return BlocListener<local.AuthFirebaseBloc, local.AuthState>(
      listener: (context, state) {
        if (state is local.AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Login successful! Welcome, ${state.user.email}"),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is local.AuthFail) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Authentication failed: ${state.message}"),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is local.AuthPending) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Authenticating... Please wait."),
              backgroundColor: Colors.orange,
            ),
          );
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
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  final email = emailController.text.trim();
                                  final password = passwordController.text.trim();

                                  debugPrint(
                                      "Attempting login with email: $email and password: $password");

                                  authBloc.add(
                                    local.AuthFirebaseLogin(
                                      email: email,
                                      password: password,
                                    ),
                                  );
                                }
                              },
                              child: const Text('Login'),
                            ),
                            if (state is local.AuthFail ||
                                state is local.AuthPending) ...[
                              const SizedBox(height: 16),
                              Text(
                                state is local.AuthFail
                                    ? "Authentication failed: ${state.message}"
                                    : "Authenticating... Please wait.",
                                style: TextStyle(
                                  color: state is local.AuthFail
                                      ? Colors.red
                                      : Colors.orange,
                                ),
                              ),
                            ],
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
