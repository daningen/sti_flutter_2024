import 'package:flutter/material.dart';
import 'package:shared/shared.dart'; // Make sure this import is correct for your project

class ParkingsView extends StatefulWidget {
  const ParkingsView({super.key, required this.index});

  final int index;

  @override
  State<ParkingsView> createState() => _ParkingsViewState();
}

class _ParkingsViewState extends State<ParkingsView> {
  final List<Item> items = [
    Item("description"),
    Item("description1"),
    Item("description2"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit items page"),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("Item: ${items[index].description}"),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            items.add(Item("description: ${items.length}"));
          });
        },
        label: const Text("Create new item"),
      ),
    );
  }
}
