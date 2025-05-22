import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';

class ToggleRouteTypeButton extends StatelessWidget {
  final MapViewModel viewModel;

  const ToggleRouteTypeButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'toggle_route_type',
      onPressed: () {
        viewModel.toggleRouteType();
      },
      backgroundColor: viewModel.routeType == 'driving' ? Colors.blue[600] : Colors.green[600],
      foregroundColor: Colors.white,
      elevation: 4,
      hoverElevation: 8,
      tooltip: viewModel.routeType == 'driving' ? 'Switch to Walking' : 'Switch to Driving',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Icon(
        viewModel.routeType == 'driving' ? Icons.directions_car : Icons.directions_walk,
        size: 28,
      ),
    );
  }
}