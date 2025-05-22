import 'package:flutter/material.dart';

class ToggleButtonsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ToggleButtonsButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'toggle_buttons',
      onPressed: onPressed,
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      elevation: 4,
      hoverElevation: 8,
      tooltip: 'Toggle Options',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add, size: 28),
    );
  }
}