import 'package:flutter/material.dart';

class ToggleButtonsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ToggleButtonsButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'toggle_buttons',
      onPressed: onPressed,
      backgroundColor: Colors.purple,
      child: const Icon(Icons.menu),
    );
  }
}