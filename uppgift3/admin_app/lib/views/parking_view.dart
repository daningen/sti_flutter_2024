// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';
import 'package:intl/intl.dart';
import '../theme_notifier.dart';

// import '../widgets/bottom_action_buttons.dart.dart';

class ParkingView extends StatefulWidget {
  const ParkingView({super.key});

  @override
  State<ParkingView> createState() => _ParkingViewState();
}

class _ParkingViewState extends State<ParkingView> {
  late Future<List<Parking>> _parkingsFuture;
  Parking? _selectedParking;
  bool _showActiveOnly = false;

  final DateFormat timeFormat =
      DateFormat('yyyy-MM-dd HH:mm'); // Format to minutes

  @override
  void initState() {
    super.initState();
    _loadParkings();
  }

  void _loadParkings() {
    setState(() {
      _parkingsFuture = ParkingRepository().getAll().then((parkings) {
        return _showActiveOnly
            ? parkings.where((p) => p.endTime == null).toList()
            : parkings;
      });
      _selectedParking = null;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking'),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showActiveOnly = false;
                    _loadParkings();
                  });
                },
                child: const Text('All Parkings'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showActiveOnly = true;
                    _loadParkings();
                  });
                },
                child: const Text('Active Parkings'),
              ),
            ],
            
            
          ),
          
          Expanded(
            child: FutureBuilder<List<Parking>>(
              future: _parkingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final parkings = snapshot.data ?? [];
                return SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                    showCheckboxColumn: false,
                    columns: const [
                      DataColumn(label: Text('VEHICLE')),
                      DataColumn(label: Text('ADDRESS')),
                      DataColumn(label: Text('START TIME')),
                      DataColumn(label: Text('END TIME')),
                    ],
                    rows: parkings.map((parking) {
                      final isSelected = parking == _selectedParking;

                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          setState(() {
                            _selectedParking =
                                selected == true ? parking : null;
                          });
                        },
                        color: WidgetStateProperty.resolveWith<Color?>(
                          (states) => isSelected ? Colors.blue[100] : null,
                        ),
                        cells: [
                          DataCell(Text(
                              parking.vehicle.target?.licensePlate ?? 'N/A')),
                          DataCell(Text(
                              parking.parkingSpace.target?.address ?? 'N/A')),
                          DataCell(Text(timeFormat.format(parking.startTime))),
                          DataCell(Text(parking.endTime != null
                              ? timeFormat.format(parking.endTime!)
                              : 'Ongoing')),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            
          ),
          // BottomActionButtons(
          //   onNew: _createParking,
          //   onEdit: () {}, // Add edit logic when needed
          //   onDelete: _deleteParking,
          //   onReload: _loadParkings,
          // ),
        ],
      ),
    );
  }
}
