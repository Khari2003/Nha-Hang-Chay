import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';

class StartNavigationButton extends StatelessWidget {
  final MapViewModel viewModel;

  const StartNavigationButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'start_navigation',
      onPressed: () {
        viewModel.startNavigation();
      },
      backgroundColor: Colors.green[600],
      foregroundColor: Colors.white,
      elevation: 4,
      hoverElevation: 8,
      tooltip: 'Start Navigation',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.play_arrow, size: 28),
    );
  }
}