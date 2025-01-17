// vehicle_navigation_bar.dart
import 'package:flutter/material.dart';

class VehicleNavigationBar extends StatelessWidget {
  final Function onHomePressed;
  final Function onReloadPressed;
  final Function onAddVehiclePressed;

  const VehicleNavigationBar({
    super.key,
    required this.onHomePressed,
    required this.onReloadPressed,
    required this.onAddVehiclePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'home',
          onPressed: () => onHomePressed(),
          child: const Icon(Icons.home),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: 'reload',
          onPressed: () => onReloadPressed(),
          child: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 16),
        FloatingActionButton.extended(
          heroTag: 'addVehicle',
          onPressed: () => onAddVehiclePressed(),
          label: const Text("Add Vehicle"),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}