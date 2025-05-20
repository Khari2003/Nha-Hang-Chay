import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';

class MyLocationButton extends StatelessWidget {
  final MapViewModel viewModel;

  const MyLocationButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'my_location',
      onPressed: () {
        if (viewModel.currentLocation != null) {
          viewModel.mapController.move(
            viewModel.currentLocation!.toLatLng(),
            viewModel.isNavigating ? 20.0 : 14,
          );
        }
      },
      child: const Icon(Icons.my_location),
    );
  }
}