import 'package:my_app/domain/entities/location.dart';

class Store {
  final String? id;
  final String name;
  final String type;
  final String? description;
  final Location? location;
  final String priceRange;
  final List<MenuItem> menu;
  final List<String> images;
  final String? owner;
  final List<String> reviews;
  final bool isApproved;
  final DateTime createdAt;
  final double rating;

  Store({
    this.id,
    required this.name,
    required this.type,
    this.description,
    this.location,
    required this.priceRange,
    required this.menu,
    required this.images,
    this.owner,
    required this.reviews,
    this.isApproved = false,
    required this.createdAt,
    this.rating = 0.0
  });
}

class MenuItem {
  final String name;
  final double price;

  MenuItem({
    required this.name,
    required this.price,
  });
}