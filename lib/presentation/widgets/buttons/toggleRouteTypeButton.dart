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
      backgroundColor: viewModel.routeType == 'driving' ? Colors.blue : Colors.green,
      child: Icon(
        viewModel.routeType == 'driving' ? Icons.directions_car : Icons.directions_walk,
      ),
    );
  }
}