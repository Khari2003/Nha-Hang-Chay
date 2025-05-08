import 'package:my_app/domain/entities/location.dart';

class Store {
  final String? id;
  final String name;
  final String? description;
  final Location? location; // Sử dụng Location từ location.dart
  final List<String> cuisine;
  final String priceRange;
  final List<String> dietaryOptions;
  final List<String> images;
  final String? owner;
  final List<String>? reviews;
  final bool isApproved;
  final DateTime createdAt;

  Store({
    this.id,
    required this.name,
    this.description,
    this.location,
    required this.cuisine,
    required this.priceRange,
    required this.dietaryOptions,
    required this.images,
    this.owner,
    this.reviews,
    this.isApproved = false,
    required this.createdAt,
  });
}