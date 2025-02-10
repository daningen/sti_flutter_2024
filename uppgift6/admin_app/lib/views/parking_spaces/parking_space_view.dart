// ignore_for_file: use_build_context_synchronously

import 'package:admin_app/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/bloc/parking_spaces/parking_space_bloc.dart';
import 'package:shared/bloc/parking_spaces/parking_space_event.dart';
import 'package:shared/bloc/parking_spaces/parking_space_state.dart';

import 'package:shared/shared.dart';
import '../../widgets/app_bar_actions.dart';
import '../../widgets/bottom_action_buttons.dart';
import 'dialog/create_parking_space_dialog.dart';
import 'dialog/edit_parking_space_dialog.dart';

class ParkingSpacesView extends StatefulWidget {
  const ParkingSpacesView({super.key});

  @override
  State<ParkingSpacesView> createState() => _ParkingSpacesViewState();
}

class _ParkingSpacesViewState extends State<ParkingSpacesView> {
  ParkingSpace? _selectedParkingSpace;

  @override
  void initState() {
    super.initState();
    _loadParkingSpaces();
  }

  void _loadParkingSpaces() {
    context.read<ParkingSpaceBloc>().add(LoadParkingSpaces());
  }

  void _deleteParkingSpace() {
    if (_selectedParkingSpace == null) return;

    context.read<ParkingSpaceBloc>().add(DeleteParkingSpace(id: _selectedParkingSpace!.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted Parking Space: ${_selectedParkingSpace!.address}')),
    );

    setState(() {
      _selectedParkingSpace = null;
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
            child: BlocBuilder<ParkingSpaceBloc, ParkingSpaceState>(
              builder: (context, state) {
                debugPrint('UI rebuilt with state: $state');

                if (state is ParkingSpaceLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ParkingSpaceLoaded) {
                  final parkingSpaces = state.parkingSpaces;
                  return SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
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
                              _selectedParkingSpace = selected == true ? space : null;
                            });
                          },
                          color: WidgetStateProperty.resolveWith<Color?>((states) => isSelected ? Colors.blue[100] : null),
                          cells: [
                            DataCell(Text(space.address)),
                            DataCell(Text('SEK ${space.pricePerHour}')),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                }
                if (state is ParkingSpaceError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const Center(child: Text('No parking spaces available.'));
              },
            ),
          ),
          BottomActionButtons(
  onNew: () => showDialog(
    context: context,
    builder: (context) => CreateParkingSpaceDialog(
      onCreate: (address, pricePerHour) {
        context
            .read<ParkingSpaceBloc>()
            .add(CreateParkingSpace(address: address, pricePerHour: pricePerHour));
      },
    ),
  ),
  onEdit: _selectedParkingSpace == null
      ? null
      : () => showDialog(
            context: context,
            builder: (context) => EditParkingSpaceDialog(
              parkingSpace: _selectedParkingSpace!,
              onEdit: (id, address, pricePerHour) {
                context.read<ParkingSpaceBloc>().add(
                      UpdateParkingSpace(
                        id: id,
                        updatedSpace: ParkingSpace(
                          id: id,
                          address: address,
                          pricePerHour: pricePerHour,
                        ),
                      ),
                    );
              },
            ),
          ),
  onDelete: _deleteParkingSpace,
  onReload: _loadParkingSpaces,
),

        ],
      ),
    );
  }
}
