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

        debugPrint('LoginView: Attempting login for username: $username');
        context.read<AuthBloc>().add(LoginRequested(
              username: username,
              password: password,
            ));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              debugPrint('Auth State changed: $state');
              if (state is AuthAuthenticated) {
                debugPrint('Login successful. Navigating to /start.');
                context.go('/start');  
              } else if (state is AuthUnauthenticated) {
                debugPrint('Login failed. Showing error.');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? 'Login failed'),
                  ),
                );
              }
            },
            builder: (context, state) {
              return Form(
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
                        enabled: state is! AuthLoading,
                        decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person)),
                        validator: Validators.validateUsername,
                        onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        focusNode: passwordFocus,
                        obscureText: true,
                        enabled: state is! AuthLoading,
                        decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock)),
                        validator: Validators.validatePassword,
                        onFieldSubmitted: (_) => save(context),
                      ),
                      const SizedBox(height: 32),
                      if (state is AuthLoading)
                        const CircularProgressIndicator()
                      else
                        ElevatedButton(
                          onPressed: () {
                            debugPrint('LoginView: Login button pressed');
                            save(context);
                          },
                          child: const Text('Login'),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
