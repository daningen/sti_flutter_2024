import 'package:flutter/material.dart';

class ExampleView extends StatelessWidget {
  const ExampleView({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Example view, tjoho $index"));
  }
}
