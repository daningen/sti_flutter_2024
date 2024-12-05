// login_view.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter for redirection
import '../auth_service.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final usernameFocus = FocusNode();
    final passwordFocus = FocusNode();
    final authService = context.watch<AuthService>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      usernameFocus.requestFocus();
    });

    save(BuildContext context) {
      if (formKey.currentState!.validate()) {
        context.read<AuthService>().login().then((_) {
          if (context.read<AuthService>().status == AuthStatus.authenticated) {
            GoRouter.of(context).go('/'); // Redirect to start page if logged in
          }
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome Back',
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 32),
                TextFormField(
                  focusNode: usernameFocus,
                  enabled: authService.status != AuthStatus.authenticating,
                  decoration: const InputDecoration(
                      labelText: 'Username', prefixIcon: Icon(Icons.person)),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a username' : null,
                  onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  focusNode: passwordFocus,
                  obscureText: true,
                  enabled: authService.status != AuthStatus.authenticating,
                  decoration: const InputDecoration(
                      labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a password' : null,
                  onFieldSubmitted: (_) => save(context),
                ),
                const SizedBox(height: 32),
                authService.status == AuthStatus.authenticating
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () => save(context),
                        child: const Text('Login'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
