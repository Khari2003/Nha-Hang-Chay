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
      backgroundColor: Colors.orange,
      child: const Icon(Icons.add_business),
    );
  }
}