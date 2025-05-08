// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../../domain/entities/coordinates.dart';

class StoreDetailWidget extends StatelessWidget {
  final String name;
  final List<String> cuisine; // Sửa từ String thành List<String>
  final String? city; // Có thể null
  final String? address; // Có thể null
  final Coordinates? coordinates; // Có thể null
  final String? priceRange;
  final String? imageURL;
  final VoidCallback onGetDirections;

  const StoreDetailWidget({
    required this.name,
    required this.cuisine,
    this.city,
    this.address,
    this.coordinates,
    this.priceRange,
    this.imageURL,
    required this.onGetDirections,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          Text('Ẩm thực: ${cuisine.isNotEmpty ? cuisine.join(', ') : "Không xác định"}'),
          if (city != null) Text('Thành phố: $city'),
          if (address != null) Text('Địa chỉ: $address'),
          if (coordinates != null) Text('Tọa độ: ${coordinates!.latitude}, ${coordinates!.longitude}'),
          if (priceRange != null) Text('Mức giá: $priceRange'),
          if (imageURL != null)
            Image.network(
              imageURL!,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
            ),
          const SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: coordinates != null ? onGetDirections : null,
            child: const Text('Chỉ đường'),
          ),
        ],
      ),
    );
  }
}