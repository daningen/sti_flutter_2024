// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
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
    final authService = context.watch<AuthService>();

    save(BuildContext context) async {
      if (formKey.currentState!.validate()) {
        final username = usernameController.text.trim();
        final password = passwordController.text.trim();

        context.read<AuthService>().login(username, password);

        // Login completed, check AuthService.status for success or failure
        // (potentially use Provider or BLoC to manage navigation state)
      }
    }

    return Scaffold(
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
                  Text('Welcome Back',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: usernameController,
                    focusNode: usernameFocus,
                    enabled: authService.status != AuthStatus.authenticating,
                    decoration: const InputDecoration(
                        labelText: 'Username', prefixIcon: Icon(Icons.person)),
                    validator: Validators.validateUsername,
                    onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    focusNode: passwordFocus,
                    obscureText: true,
                    enabled: authService.status != AuthStatus.authenticating,
                    decoration: const InputDecoration(
                        labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                    validator: Validators.validatePassword,
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
      ),
    );
  }
}
