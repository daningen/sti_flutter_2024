import 'package:flutter/material.dart';

class ItemsView extends StatelessWidget {
  const ItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Items Page"),
      ),
      body: const Center(
        child: Text(
          "This is a simple view",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
