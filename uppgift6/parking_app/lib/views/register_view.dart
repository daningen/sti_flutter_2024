import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/bloc/auth/auth_firebase_bloc.dart' as local;

import '../utils/validators.dart';
import 'person/dialog/create_person_dialog.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('RegisterView is being built');
    final formKey = GlobalKey<FormState>();

    final emailController =
        TextEditingController(text: 'reg1@test.com'); // Prefilled email
    final passwordController =
        TextEditingController(text: 'password'); // Prefilled password

    final authBloc = context.read<local.AuthFirebaseBloc>();

    void register() {
      if (formKey.currentState!.validate()) {
        final email = emailController.text.trim();
        final password = passwordController.text.trim();

        authBloc
            .add(local.AuthFirebaseRegister(email: email, password: password));
      }
    }

    return BlocListener<local.AuthFirebaseBloc, local.AuthState>(
      listener: (context, state) {
        if (state is local.AuthAuthenticatedNoUser) {
          debugPrint(
              '✅ Registration successful for ${state.email}, prompting for person creation.');

          // Show dialog for creating a person
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CreatePersonDialog(
              authId: state.authId, // Use Firebase authId
              onCreate: (authId, name, ssn) {
                debugPrint(
                    '🆕 Creating person: $name, $ssn (Linked to authId: $authId)');

                // Dispatch event to create person in Firestore
                context.read<local.AuthFirebaseBloc>().add(
                      local.AuthFirebaseCreatePerson(
                        authId: authId,
                        name: name,
                        ssn: ssn,
                      ),
                    );
              },
            ),
          );
        } else if (state is local.AuthAuthenticated) {
          // ✅ Listen for Authenticated state
          debugPrint(
              '✅ Person created successfully & user is now authenticated');
          Navigator.of(context).pop(); // Close the dialog
          GoRouter.of(context).go('/start'); // ✅ Redirect to start
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              debugPrint('⬅️ Going back to Login');
              GoRouter.of(context).go('/login'); // ✅ Navigate back to Login
            },
          ),
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
                    Text('Create an Account',
                        style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Email', prefixIcon: Icon(Icons.email)),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: register,
                      child: const Text('Register'),
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
