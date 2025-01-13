import 'package:flutter/material.dart';

class BottomActionButtons extends StatelessWidget {
  final VoidCallback onNew; // Required for all views
  final VoidCallback? onEdit; // Nullable to support conditional enabling
  final VoidCallback? onDelete; // Nullable to support conditional enabling
  final VoidCallback onReload; // Required for all views
  final Color buttonColor;
  final Color textColor;

  const BottomActionButtons({
    required this.onNew,
    this.onEdit, // Allow nullable for flexibility
    this.onDelete, // Allow nullable for flexibility
    required this.onReload,
    this.buttonColor = Colors.lightBlue,
    this.textColor = Colors.white,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: onNew, // Always enabled
            icon: const Icon(Icons.add),
            label: const Text('New'),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: textColor,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onEdit, // Nullable, can be disabled
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: textColor,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onDelete, // Nullable, can be disabled
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onReload, // Always enabled
            icon: const Icon(Icons.refresh),
            label: const Text('Reload'),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
