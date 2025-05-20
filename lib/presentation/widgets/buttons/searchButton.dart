// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';
import 'package:my_app/presentation/screens/search/searchPlacesScreen.dart';

class SearchButton extends StatelessWidget {
  final MapViewModel viewModel;

  const SearchButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'search_button',
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchPlacesScreen(),
          ),
        );

        if (result != null && result is Map<String, String>) {
          final double lat = double.parse(result['lat']!);
          final double lon = double.parse(result['lon']!);
          final location = Coordinates(latitude: lat, longitude: lon);
          final double? radius =
              result['radius'] != null ? double.parse(result['radius']!) : null;

          viewModel.setSearchedLocation(
            location,
            result['type']!,
            result['name']!,
            radius: radius,
          );

          if (result['type'] == 'exact') {
            await viewModel.updateRouteToStore(location).then((_) {
              if (viewModel.routeCoordinates.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Không thể vẽ đường đi.'),
                  ),
                );
              }
            });
          }
        }
      },
      child: const Icon(Icons.search),
    );
  }
}