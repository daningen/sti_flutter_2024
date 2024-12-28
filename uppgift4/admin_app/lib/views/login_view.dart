// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/bloc/auth/auth_bloc.dart';
import 'package:shared/bloc/auth/auth_event.dart';
import 'package:shared/bloc/auth/auth_state.dart';

import '../utils/validators.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final usernameFocus = FocusNode();
    final passwordFocus = FocusNode();

    void save(BuildContext context) {
      if (formKey.currentState!.validate()) {
        final username = usernameController.text.trim();
        final password = passwordController.text.trim();

        // Dispatch the login event to the AuthBloc
        context
            .read<AuthBloc>()
            .add(LoginRequested(username: username, password: password));
      }
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Redirect to the start page on successful login
          GoRouter.of(context).go('/vehicles');
        } else if (state is AuthUnauthenticated && state.errorMessage != null) {
          // Show error message if login fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
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
                      controller: usernameController,
                      focusNode: usernameFocus,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: Validators.validateUsername,
                      onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      focusNode: passwordFocus,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: Validators.validatePassword,
                      onFieldSubmitted: (_) => save(context),
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return ElevatedButton(
                          onPressed: () => save(context),
                          child: const Text('Login'),
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
