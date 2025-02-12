import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/validators.dart';
import '../bloc/auth/auth_firebase_bloc.dart' as local;
import 'person/dialog/create_person_dialog.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('RegisterView is being built');

    final formKey = GlobalKey<FormState>();

    // Prefilled email and password for testing
    final emailController =
        TextEditingController(text: 'reg1@test.com'); // Prefilled email
    final passwordController =
        TextEditingController(text: 'password'); 

    final authBloc = context.read<local.AuthFirebaseBloc>();

    void register() {
      if (formKey.currentState!.validate()) {
        final email = emailController.text.trim();
        final password = passwordController.text.trim();

        authBloc.add(local.AuthFirebaseRegister(email: email, password: password));
      }
    }

    return BlocListener<local.AuthFirebaseBloc, local.AuthState>(
      listener: (context, state) {
        if (state is local.AuthAuthenticatedNoUser) {
          debugPrint('✅ Registration successful, but missing person info.');

          // Show Create Person Dialog
          showDialog(
            context: context,
            barrierDismissible: false, // Prevent closing without input
            builder: (context) => CreatePersonDialog(
              onCreate: (name, ssn) {
                debugPrint('🆕 Creating person: $name, $ssn');

                // Dispatch event to create person in Firestore
                context.read<local.AuthFirebaseBloc>().add(
                      local.AuthFirebaseCreatePerson(
                        authId: state.authId, // Use Firebase UID
                        name: name,
                        ssn: ssn,
                      ),
                    );
              },
            ),
          );
        } 
        
        if (state is local.AuthFirebasePersonCreated) {
          debugPrint('✅ Person created successfully');
          Navigator.of(context).pop(); // Close CreatePersonDialog
          Navigator.pushReplacementNamed(context, '/welcome'); // Go to Welcome page
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Register')),
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
                    Text('Create an Account', style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
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
