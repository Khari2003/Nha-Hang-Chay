import 'package:my_app/domain/entities/coordinates.dart';
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
    this.rating = 0.0,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['_id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      location: json['location'] != null
          ? Location(
              address: json['location']['address'],
              city: json['location']['city'],
              postalCode: json['location']['postalCode'],
              country: json['location']['country'],
              coordinates: json['location']['coordinates'] != null
                  ? Coordinates(
                      latitude: json['location']['coordinates'][1],
                      longitude: json['location']['coordinates'][0],
                    )
                  : null,
            )
          : null,
      priceRange: json['priceRange'],
      menu: List<MenuItem>.from(json['menu']?.map((item) => MenuItem(
            name: item['name'],
            price: item['price'].toDouble(),
          )) ?? []),
      images: List<String>.from(json['images'] ?? []),
      owner: json['owner'],
      reviews: List<String>.from(json['reviews'] ?? []),
      isApproved: json['isApproved'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      rating: json['rating']?.toDouble() ?? 0.0,
    );
  }
}

class MenuItem {
  final String name;
  final double price;

  MenuItem({
    required this.name,
    required this.price,
  });
}