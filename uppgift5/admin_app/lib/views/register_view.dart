import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_app/bloc/auth/auth_firebase_bloc.dart' as local;
import 'package:go_router/go_router.dart';

import '../utils/validators.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    void register() {
      if (formKey.currentState!.validate()) {
        context.read<local.AuthFirebaseBloc>().add(
              local.AuthFirebaseRegister(
                email: emailController.text.trim(),
                password: passwordController.text.trim(),
              ),
            );
      }
    }

    return BlocListener<local.AuthFirebaseBloc, local.AuthState>(
      listener: (context, state) {
        if (state is local.AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          GoRouter.of(context).go('/login'); // Redirect to login
        } else if (state is local.AuthFail) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Register')),
        body: Center(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<local.AuthFirebaseBloc, local.AuthState>(
                      builder: (context, state) {
                        if (state is local.AuthPending) {
                          return const CircularProgressIndicator();
                        }
                        return ElevatedButton(
                          onPressed: register,
                          child: const Text('Register'),
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
