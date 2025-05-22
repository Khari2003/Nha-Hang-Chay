import 'package:flutter/material.dart';

class CreateStoreButton extends StatelessWidget {
  const CreateStoreButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'create_store',
      onPressed: () {
        Navigator.pushNamed(context, '/create-store');
      },
      backgroundColor: Colors.orange[600],
      foregroundColor: Colors.white,
      elevation: 4,
      hoverElevation: 8,
      tooltip: 'Create New Store',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add_business, size: 28),
    );
  }
}