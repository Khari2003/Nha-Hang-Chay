import 'package:my_app/domain/entities/location.dart';

class Store {
  final String? id;
  final String name;
  final String type;
  final String? description;
  final Location? location;
  final String priceRange;
  final List<String> images;
  final String? owner;
  final List<String>? reviews;
  final bool isApproved;
  final DateTime createdAt;

  Store({
    this.id,
    required this.name,
    required this.type,
    this.description,
    this.location,
    required this.priceRange,
    required this.images,
    this.owner,
    this.reviews,
    this.isApproved = false,
    required this.createdAt,
  });
}