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
      backgroundColor: Colors.red[600],
      foregroundColor: Colors.white,
      elevation: 4,
      hoverElevation: 8,
      tooltip: 'End Navigation',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.stop, size: 28),
    );
  }
}