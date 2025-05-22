import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';

class CancelAllButton extends StatelessWidget {
  final MapViewModel viewModel;

  const CancelAllButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'cancel_all',
      onPressed: () {
        viewModel.resetToInitialState();
        if (viewModel.currentLocation != null) {
          viewModel.mapController.move(
            viewModel.currentLocation!.toLatLng(),
            14.0,
          );
        }
      },
      backgroundColor: Colors.grey[700],
      foregroundColor: Colors.white,
      elevation: 4,
      hoverElevation: 8,
      tooltip: 'Cancel All Actions',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.cancel, size: 28),
    );
  }
}