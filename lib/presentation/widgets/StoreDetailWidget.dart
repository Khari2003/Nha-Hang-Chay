// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../../domain/entities/coordinates.dart';

class StoreDetailWidget extends StatelessWidget {
  final String name;
  final String? city;
  final String? address;
  final Coordinates? coordinates;
  final String? priceRange;
  final String? imageURL;
  final String type; // Thêm type
  final bool isApproved; // Thêm isApproved
  final VoidCallback onGetDirections;

  const StoreDetailWidget({
    required this.name,
    this.city,
    this.address,
    this.coordinates,
    this.priceRange,
    this.imageURL,
    required this.type,
    required this.isApproved,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text('Loại: $type'),
          if (city != null) Text('Thành phố: $city'),
          if (address != null) Text('Địa chỉ: $address'),
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