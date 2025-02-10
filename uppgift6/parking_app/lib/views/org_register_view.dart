// import 'package:firebase_repositories/firebase_repositories.dart';
// import 'package:flutter/material.dart';
// import 'package:shared/shared.dart';
// import '../../../utils/validators.dart';

// class RegisterView extends StatelessWidget {
//   const RegisterView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final formKey = GlobalKey<FormState>();
//     final nameController = TextEditingController();
//     final ssnController = TextEditingController();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Register User'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: nameController,
//                 decoration: const InputDecoration(labelText: 'Name'),
//                 validator: Validators.validateName,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: ssnController,
//                 decoration: const InputDecoration(labelText: 'SSN (yymmdd)'),
//                 validator: Validators.validateSSN,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: () {
//                   if (formKey.currentState!.validate()) {
//                     final name = nameController.text.trim();
//                     final ssn = ssnController.text.trim();

//                     // Create a new Person object
//                     final newPerson = Person(
//                       id: '', // Placeholder ID; replace with actual logic if needed
//                       name: name,
//                       ssn: ssn,
//                     );

//                     // Example: Save newPerson using a repository
//                     PersonRepository().create(newPerson);

//                     // Provide feedback to the user
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('User "$name" registered successfully')),
//                     );

//                     // Optionally, navigate back or to another screen
//                     Navigator.of(context).pop();
//                   }
//                 },
//                 child: const Text('Register'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
