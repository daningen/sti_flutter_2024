// ignore_for_file: use_build_context_synchronously

import 'package:admin_app/app_constants.dart';
import 'package:admin_app/app_theme.dart';
import 'package:admin_app/utils/validators.dart';
import 'package:admin_app/widgets/bottom_action_buttons.dart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';

import '../theme_notifier.dart';

class VehiclesView extends StatefulWidget {
  const VehiclesView({super.key});

  @override
  State<VehiclesView> createState() => _VehiclesViewState();
}

class _VehiclesViewState extends State<VehiclesView> {
  late Future<List<Vehicle>> _vehiclesFuture;
  late Future<List<Person>> _personsFuture;
  Vehicle? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _personsFuture = PersonRepository().getAll();
  }

  void _loadVehicles() {
    setState(() {
      _vehiclesFuture = VehicleRepository().getAll();
      _selectedVehicle = null;
    });
  }

  void _createVehicle() {
    final formKey = GlobalKey<FormState>();
    final licensePlateController = TextEditingController();
    String? selectedVehicleType;
    Person? selectedOwner;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Vehicle'),
          content: FutureBuilder<List<Person>>(
            future: _personsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final persons = snapshot.data ?? [];
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: licensePlateController,
                      decoration:
                          const InputDecoration(labelText: 'License Plate'),
                      validator: Validators.validateLicensePlate,
                      onChanged: (value) {
                        licensePlateController.text = value.toUpperCase();
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: vehicleTypes
                          .map((type) =>
                              DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) => selectedVehicleType = value,
                      validator: (value) =>
                          value == null ? 'Please select a vehicle type' : null,
                    ),
                    DropdownButtonFormField<Person>(
                      decoration: const InputDecoration(labelText: 'Owner'),
                      items: persons.map((person) {
                        return DropdownMenuItem<Person>(
                          value: person,
                          child: Text(person.name),
                        );
                      }).toList(),
                      onChanged: (person) => selectedOwner = person,
                      validator: (value) =>
                          value == null ? 'Please select an owner' : null,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newVehicle = Vehicle(
                    licensePlate: licensePlateController.text,
                    vehicleType: selectedVehicleType!,
                  );
                  newVehicle.setOwner(selectedOwner!);

                  VehicleRepository().create(newVehicle).then((_) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vehicle created')),
                    );
                    _loadVehicles();
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

  void _editVehicle() {
    if (_selectedVehicle == null) return;

    final formKey = GlobalKey<FormState>();
    final licensePlateController =
        TextEditingController(text: _selectedVehicle!.licensePlate);
    String? selectedVehicleType = _selectedVehicle!.vehicleType;
    Person? selectedOwner;

    _personsFuture.then((persons) {
      selectedOwner = persons.firstWhere(
        (person) => person.id == _selectedVehicle!.owner.target?.id,
      );

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Vehicle'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: licensePlateController,
                    decoration:
                        const InputDecoration(labelText: 'License Plate'),
                    validator: Validators.validateLicensePlate,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedVehicleType,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: vehicleTypes
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => selectedVehicleType = value,
                  ),
                  DropdownButtonFormField<Person>(
                    value: selectedOwner,
                    decoration: const InputDecoration(labelText: 'Owner'),
                    items: persons.map((person) {
                      return DropdownMenuItem<Person>(
                        value: person,
                        child: Text(person.name),
                      );
                    }).toList(),
                    onChanged: (person) => selectedOwner = person,
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
                    _selectedVehicle!.licensePlate =
                        licensePlateController.text;
                    _selectedVehicle!.vehicleType = selectedVehicleType!;
                    _selectedVehicle!.setOwner(selectedOwner!);

                    VehicleRepository()
                        .update(_selectedVehicle!.id, _selectedVehicle!)
                        .then((_) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vehicle updated')),
                      );
                      _loadVehicles();
                    });
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    });
  }

  void _deleteVehicle() {
    if (_selectedVehicle == null) return;

    VehicleRepository().delete(_selectedVehicle!.id).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted Vehicle: ${_selectedVehicle!.id}')),
      );
      setState(() {
        _selectedVehicle = null;
      });
      _loadVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles Management'),
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
            child: FutureBuilder<List<Vehicle>>(
              future: _vehiclesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final vehicles = snapshot.data ?? [];
                return SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                      if (Theme.of(context).brightness == Brightness.dark) {
                        return AppColors.headingRowColor;
                      }
                      return null;
                    }),
                    // headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                    showCheckboxColumn: false,
                    columns: const [
                      DataColumn(label: Text('LICENSE PLATE')),
                      DataColumn(label: Text('TYPE')),
                      DataColumn(label: Text('OWNER')),
                    ],
                    rows: vehicles.map((vehicle) {
                      final isSelected = vehicle == _selectedVehicle;
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          setState(() {
                            _selectedVehicle =
                                selected == true ? vehicle : null;
                          });
                        },
                        color: WidgetStateProperty.resolveWith<Color?>(
                            (states) => isSelected ? Colors.blue[100] : null),
                        cells: [
                          DataCell(Text(vehicle.licensePlate)),
                          DataCell(Text(vehicle.vehicleType)),
                          DataCell(
                              Text(vehicle.owner.target?.name ?? 'Unknown')),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          BottomActionButtons(
            onNew: _createVehicle,
            onEdit: _editVehicle,
            onDelete: _deleteVehicle,
            onReload: _loadVehicles,
          ),
        ],
      ),
    );
  }
}
