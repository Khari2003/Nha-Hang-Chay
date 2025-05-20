import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';

class EndNavigationButton extends StatelessWidget {
  final MapViewModel viewModel;

  const EndNavigationButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'end_navigation',
      onPressed: () {
        viewModel.resetToInitialState();
      },
      backgroundColor: Colors.red,
      child: const Icon(Icons.stop),
    );
  }
}