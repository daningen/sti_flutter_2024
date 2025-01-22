// ignore_for_file: use_build_context_synchronously

import 'package:admin_app/app_theme.dart';
import 'package:admin_app/utils/validators.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';

import 'package:shared/shared.dart';
import '../../widgets/app_bar_actions.dart';
import '../../widgets/bottom_action_buttons.dart';

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
                  validator: Validators.validateAddress,
                ),
                TextFormField(
                  controller: priceController,
                  decoration:
                      const InputDecoration(labelText: 'Price (SEK/hr)'),
                  keyboardType: TextInputType.number,
                  validator: Validators.validatePrice,
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
                  try {
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
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Failed to create parking space: $error')),
                      );
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid price format')),
                    );
                  }
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
                  validator: Validators.validateAddress,
                ),
                TextFormField(
                  controller: priceController,
                  decoration:
                      const InputDecoration(labelText: 'Price (SEK/hr)'),
                  keyboardType: TextInputType.number,
                  validator: Validators.validatePrice,
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
                  try {
                    final updatedParkingSpace = _selectedParkingSpace!.copyWith(
                      address: addressController.text,
                      pricePerHour: int.parse(priceController.text),
                    );

                    ParkingSpaceRepository()
                        .update(updatedParkingSpace.id, updatedParkingSpace)
                        .then((_) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Parking Space updated')),
                      );
                      _loadParkingSpaces();
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Failed to update parking space: $error')),
                      );
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid price format')),
                    );
                  }
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
            content: Text(
                'Deleted Parking Space: ${_selectedParkingSpace!.address}')),
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
        actions: const [
          AppBarActions(),
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
                    headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                      if (Theme.of(context).brightness == Brightness.dark) {
                        return AppColors.headingRowColor;
                      }
                      return null;
                    }),
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
