import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';

class ToggleStoreListButton extends StatelessWidget {
  final MapViewModel viewModel;

  const ToggleStoreListButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'toggle_store_list',
      onPressed: () {
        viewModel.toggleStoreListVisibility();
      },
      child: Icon(
        viewModel.isStoreListVisible ? Icons.close : Icons.list,
      ),
    );
  }
}