import 'package:flutter/material.dart';
import 'package:shared/shared.dart'; // Make sure this import is correct for your project

class ItemsView extends StatefulWidget {
  const ItemsView({super.key, required this.index});

  final int index;

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  final List<Item> items = [
    Item("newItem1"),
    Item("newItem2"),
    Item("newItem2"),
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
        onPressed: () async {
          var result = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Create new item"),
                content: TextField(
                  decoration:
                      const InputDecoration(hintText: "Enter item description"),
                  onSubmitted: (value) {
                    Navigator.of(context).pop(value);
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              );
            },
          );

          if (result != null) {
            setState(() {
              items.add(Item(result));
            });
          }
        },
        label: const Text("Create new item"),
      ),
    );
  }
}
