// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../../domain/entities/location.dart';

class StoreDetailWidget extends StatelessWidget {
  final String name;
  final String category;
  final String address;
  final Location coordinates;
  final String? phoneNumber;
  final String? website;
  final String? priceLevel;
  final String? openingHours;
  final String? imageURL;
  final VoidCallback onGetDirections;

  const StoreDetailWidget({
    required this.name,
    required this.category,
    required this.address,
    required this.coordinates,
    this.phoneNumber,
    this.website,
    this.priceLevel,
    this.openingHours,
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
          Text(name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8.0),
          Text('Danh mục: $category'),
          Text('Địa chỉ: $address'),
          if (phoneNumber != null) Text('Số điện thoại: $phoneNumber'),
          if (website != null) Text('Website: $website'),
          if (priceLevel != null) Text('Mức giá: $priceLevel'),
          if (openingHours != null) Text('Giờ mở cửa: $openingHours'),
          if (imageURL != null)
            Image.network(imageURL!, height: 100, fit: BoxFit.cover),
          const SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: onGetDirections,
            child: const Text('Chỉ đường'),
          ),
        ],
      ),
    );
  }
}