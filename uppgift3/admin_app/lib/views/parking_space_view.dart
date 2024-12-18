// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';
import '../theme_notifier.dart';

// import '../utils/validators.dart';
import '../widgets/bottom_action_buttons.dart.dart';

class ParkingSpacesView extends StatefulWidget {
  const ParkingSpacesView({super.key});

  @override
  State<ParkingSpacesView> createState() => _ParkingSpacesViewState();
}

class _ParkingSpacesViewState extends State<ParkingSpacesView> {
  late Future<List<ParkingSpace>> _parkingSpacesFuture;
  ParkingSpace? _selectedParkingSpace;

  @override
  void initState() {
    super.initState();
    _loadParkingSpaces();
  }

  void _loadParkingSpaces() {
    setState(() {
      _parkingSpacesFuture = ParkingSpaceRepository().getAll();
      _selectedParkingSpace = null; // Clear selection on reload
    });
  }

  void _createParkingSpace() {
    final formKey = GlobalKey<FormState>();
    final addressController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Parking Space'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  // validator: Validators.validateName,
                ),
                TextFormField(
                  controller: priceController,
                  decoration:
                      const InputDecoration(labelText: 'Price (SEK/hr)'),
                  keyboardType: TextInputType.number,
                  // validator: Validators.validatePositiveNumber,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newParkingSpace = ParkingSpace(
                    address: addressController.text,
                    pricePerHour: int.parse(priceController.text),
                  );
                  ParkingSpaceRepository().create(newParkingSpace).then((_) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Parking Space created')),
                    );
                    _loadParkingSpaces();
                  });
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _editParkingSpace() {
    if (_selectedParkingSpace == null) return;

    final formKey = GlobalKey<FormState>();
    final addressController =
        TextEditingController(text: _selectedParkingSpace!.address);
    final priceController = TextEditingController(
        text: _selectedParkingSpace!.pricePerHour.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Parking Space'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  // validator: Validators.validateName,
                ),
                TextFormField(
                  controller: priceController,
                  decoration:
                      const InputDecoration(labelText: 'Price (SEK/hr)'),
                  keyboardType: TextInputType.number,
                  // validator: Validators.validatePositiveNumber,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _selectedParkingSpace!.address = addressController.text;
                  _selectedParkingSpace!.pricePerHour =
                      int.parse(priceController.text);

                  ParkingSpaceRepository()
                      .update(_selectedParkingSpace!.id, _selectedParkingSpace!)
                      .then((_) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Parking Space updated')),
                    );
                    _loadParkingSpaces();
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteParkingSpace() {
    if (_selectedParkingSpace == null) return;

    ParkingSpaceRepository().delete(_selectedParkingSpace!.id).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Deleted Parking Space: ${_selectedParkingSpace!.id}')),
      );
      setState(() {
        _selectedParkingSpace = null;
      });
      _loadParkingSpaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Spaces Management'),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeNotifier>(context).themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ParkingSpace>>(
              future: _parkingSpacesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final parkingSpaces = snapshot.data ?? [];
                return SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                    showCheckboxColumn: false,
                    columns: const [
                      DataColumn(label: Text('ADDRESS')),
                      DataColumn(label: Text('PRICE (SEK/HOUR)')),
                    ],
                    rows: parkingSpaces.map((space) {
                      final isSelected = space == _selectedParkingSpace;
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          setState(() {
                            _selectedParkingSpace =
                                selected == true ? space : null;
                          });
                        },
                        color: WidgetStateProperty.resolveWith<Color?>(
                            (states) => isSelected ? Colors.blue[100] : null),
                        cells: [
                          DataCell(Text(space.address)),
                          DataCell(Text('SEK ${space.pricePerHour}')),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          BottomActionButtons(
            onNew: _createParkingSpace,
            onEdit: _editParkingSpace,
            onDelete: _deleteParkingSpace,
            onReload: _loadParkingSpaces,
          ),
        ],
      ),
    );
  }
}
