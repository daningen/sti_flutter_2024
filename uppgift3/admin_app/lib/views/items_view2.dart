// import 'package:client_repositories/async_http_repos.dart';
// import 'package:flutter/material.dart';
// import 'package:shared/shared.dart';

// class ItemsView extends StatefulWidget {
//   ItemsView({super.key});

//   @override
//   State<ItemsView> createState() => _ItemsViewState();
// }

// class _ItemsViewState extends State<ItemsView> {
//   Future<List<Item>> getItems = ItemRepository().getAll();

//   int _selectedIndex = -1;
//   Item? selectedItem = null;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Edit items page"),
//       ),
//       body: FutureBuilder<List<Item>>(
//         future: getItems,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             return RefreshIndicator(
//               onRefresh: () async {
//                 var items = await ItemRepository().getAll();
//                 setState(() {
//                   getItems = Future.value(items);
//                 });
//               },
//               child: ListView.builder(
//                   itemCount: snapshot.data!.length,
//                   itemBuilder: (context, index) {
//                     var item = snapshot.data![index];
//                     return ListTile(
//                       selected: index == _selectedIndex,
//                       selectedTileColor: Colors.blue[100],
//                       onTap: () {
//                         setState(() {
//                           _selectedIndex = index;
//                           selectedItem = item;
//                         });
//                       },
//                       title: Text(item.description),
//                     );
//                   }),
//             );
//           }

//           if (snapshot.hasError) {
//             return Text('Error: ${snapshot.error}');
//           }

//           return const CircularProgressIndicator();
//         },
//       ),
//       // add gap to row items
//       floatingActionButton: AnimatedActionButtons(
//         selectedItem: selectedItem,
//         onClear: () {
//           setState(() {
//             _selectedIndex = -1;
//             selectedItem = null;
//           });
//         },
//         onItemDeleted: (item) async {
//           await ItemRepository().delete(item.id);

//           if (context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content:
//                     Text("Item: ${item.description}, deleted successfully")));
//           }

//           setState(() {
//             getItems = ItemRepository().getAll();
//           });
//         },
//         onItemCreated: (item) async {
//           await ItemRepository().create(item);

//           if (context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content:
//                     Text("Item: ${item.description}, created successfully")));
//           }

//           setState(() {
//             getItems = ItemRepository().getAll();
//           });
//         },
//         onItemEdited: (item) async {
//           await ItemRepository().update(item.id, item);

//           if (context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content:
//                     Text("Item: ${item.description}, updated successfully")));
//           }

//           setState(() {
//             getItems = ItemRepository().getAll();
//           });
//         },
//       ),
//     );
//   }
// }

// class ItemActionsWidget extends StatelessWidget {
//   const ItemActionsWidget(
//       {super.key, required this.item, required this.callback});

//   final Item item;

//   final Function() callback;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 100,
//       color: Colors.deepOrange,
//       child: OverflowBar(
//         children: [
//           TextButton(onPressed: () => {}, child: const Text("Edit")),
//           TextButton(onPressed: () => {}, child: const Text("Delete")),
//           TextButton(onPressed: callback, child: const Text("Clear selection"))
//         ],
//       ),
//     );
//   }
// }

// class AnimatedActionButtons extends StatelessWidget {
//   final Item? selectedItem;
//   final VoidCallback onClear;
//   final Function(Item item) onItemCreated;
//   final Function(Item item) onItemEdited;
//   final Function(Item item) onItemDeleted;

//   const AnimatedActionButtons({
//     required this.selectedItem,
//     required this.onClear,
//     required this.onItemCreated,
//     super.key,
//     required this.onItemEdited,
//     required this.onItemDeleted,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return OverflowBar(
//       alignment: MainAxisAlignment.end,
//       spacing: 8,
//       children: [
//         AnimatedSize(
//           alignment: Alignment.centerRight,
//           duration: const Duration(milliseconds: 200),
//           child: selectedItem != null
//               ? FloatingActionButton(
//                   onPressed: () async {
//                     var result = await editItemDialog(context, selectedItem!);

//                     if (result != null) {
//                       onItemEdited(result);
//                     }
//                   },
//                   child: const Icon(Icons.edit),
//                 )
//               : const SizedBox.shrink(),
//         ),
//         AnimatedSize(
//           alignment: Alignment.centerRight,
//           duration: const Duration(milliseconds: 200),
//           reverseDuration: const Duration(milliseconds: 200),
//           child: selectedItem != null
//               ? FloatingActionButton(
//                   onPressed: () => onItemDeleted(selectedItem!),
//                   child: const Icon(Icons.delete),
//                 )
//               : const SizedBox.shrink(),
//         ),
//         AnimatedSize(
//           alignment: Alignment.centerRight,
//           duration: const Duration(milliseconds: 200),
//           child: selectedItem != null
//               ? FloatingActionButton.extended(
//                   label: const Text("Clear selection"),
//                   onPressed: onClear,
//                 )
//               : FloatingActionButton.extended(
//                   label: const Text("Add item"),
//                   onPressed: () async {
//                     var result = await createItemDialog(context);

//                     if (result != null) {
//                       onItemCreated(Item(result));
//                     }
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   Future<String?> createItemDialog(BuildContext context) {
//     return showModalBottomSheet<String>(
//         context: context,
//         builder: (context) {
//           String? description;
//           String? more;

//           FocusNode focusNode = FocusNode();

//           final formKey = GlobalKey<FormState>();

//           save() {
//             if (formKey.currentState!.validate()) {
//               formKey.currentState!.save();
//               Navigator.of(context).pop(description);
//             }
//           }

//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               const Text(
//                 "Create new item",
//                 style: TextStyle(fontSize: 24),
//                 textAlign: TextAlign.start,
//               ),
//               Divider(),
//               Expanded(
//                 child: Form(
//                   key: formKey,
//                   child: Column(
//                     children: [
//                       // add big Title text
//                       TextFormField(
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Please provide a description";
//                           }
//                           return null;
//                         },
//                         autofocus: true,
//                         decoration: const InputDecoration(
//                             hintText: "Enter item description"),
//                         onFieldSubmitted: (_) {
//                           focusNode.requestFocus();
//                         },
//                         onSaved: (newValue) => description = newValue,
//                       ),
//                       TextFormField(
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Please provide something more";
//                           }
//                           return null;
//                         },
//                         onSaved: (newValue) => more = newValue,
//                         focusNode: focusNode,
//                         onFieldSubmitted: (_) => save(),
//                         decoration: const InputDecoration(
//                             hintText: "Enter something more"),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               OverflowBar(
//                 spacing: 8,
//                 children: [
//                   FilledButton.tonal(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text("Cancel")),
//                   FilledButton(
//                       onPressed: () => save(), child: const Text("Create")),
//                 ],
//               )
//             ]),
//           );
//         });
//   }

//   Future<Item?> editItemDialog(BuildContext context, Item existingItem) {
//     return showModalBottomSheet<Item>(
//         context: context,
//         builder: (context) {
//           String? description =
//               existingItem.description; // Pre-fill with existing item
//           String? more;
//           FocusNode focusNode = FocusNode();
//           final formKey = GlobalKey<FormState>();

//           save() {
//             if (formKey.currentState!.validate()) {
//               formKey.currentState!.save();
//               Navigator.of(context).pop(Item(description!, existingItem.id));
//             }
//           }

//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               const Text(
//                 "Edit item", // Changed title
//                 style: TextStyle(fontSize: 24),
//                 textAlign: TextAlign.start,
//               ),
//               Divider(),
//               Expanded(
//                 child: Form(
//                   key: formKey,
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         initialValue: existingItem
//                             .description, // Pre-fill with existing item
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Please provide a description";
//                           }
//                           return null;
//                         },
//                         autofocus: true,
//                         decoration: const InputDecoration(
//                             hintText: "Enter item description"),
//                         onFieldSubmitted: (_) {
//                           focusNode.requestFocus();
//                         },
//                         onSaved: (newValue) => description = newValue,
//                       ),
//                       TextFormField(
//                         initialValue: more, // Pre-fill more field if needed
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Please provide something more";
//                           }
//                           return null;
//                         },
//                         onSaved: (newValue) => more = newValue,
//                         focusNode: focusNode,
//                         onFieldSubmitted: (_) => save(),
//                         decoration: const InputDecoration(
//                             hintText: "Enter something more"),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               OverflowBar(
//                 spacing: 8,
//                 children: [
//                   FilledButton.tonal(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text("Cancel")),
//                   FilledButton(
//                       onPressed: () => save(),
//                       child: const Text("Save") // Changed button text
//                       ),
//                 ],
//               )
//             ]),
//           );
//         });
//   }
// }
