import 'package:equatable/equatable.dart';
import 'package:my_app/domain/entities/location.dart';
import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/domain/entities/store.dart';

// Define valid store types matching server enum
const List<String> validStoreTypes = [
  'chay-phat-giao',
  'chay-a-au',
  'chay-hien-dai',
  'com-chay-binh-dan',
  'buffet-chay',
  'chay-ton-giao-khac',
];

class StoreModel extends Store with EquatableMixin {
  StoreModel({
    super.id,
    required super.name,
    required super.type,
    super.description,
    super.location,
    required super.priceRange,
    required super.menu,
    required super.images,
    required super.owner,
    required super.reviews,
    super.isApproved = false,
    required super.createdAt,
    super.rating = 0.0,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    Coordinates? coordinates;
    if (json['location']?['coordinates']?['coordinates'] != null) {
      coordinates = Coordinates(
        longitude: (json['location']['coordinates']['coordinates'][0] as num).toDouble(),
        latitude: (json['location']['coordinates']['coordinates'][1] as num).toDouble(),
      );
    }

    // Handle reviews as a list of objects or null
    final reviewsList = json['reviews'] != null && json['reviews'] is List<dynamic>
        ? (json['reviews'] as List<dynamic>)
            .asMap()
            .entries
            .where((entry) => entry.value is Map<String, dynamic> && entry.value['_id'] != null)
            .map((entry) => (entry.value['_id'] as Object).toString())
            .toList()
        : <String>[];

    return StoreModel(
      id: json['_id']?.toString(),
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'chay-hien-dai',
      description: json['description'] as String?,
      location: json['location'] != null
          ? Location(
              address: json['location']['address'] as String?,
              city: json['location']['city'] as String?,
              postalCode: json['location']['postalCode'] as String?,
              country: json['location']['country'] as String?,
              coordinates: coordinates,
            )
          : null,
      priceRange: json['priceRange'] as String? ?? 'Moderate',
      menu: (json['menu'] as List<dynamic>?)
              ?.map((item) => MenuItem(
                    name: item['name'] as String? ?? '',
                    price: (item['price'] as num?)?.toDouble() ?? 0.0,
                  ))
              .toList() ??
          [],
      images: List<String>.from(json['images'] ?? []),
      owner: json['owner']?.toString(),
      reviews: reviewsList, // List of review IDs
      isApproved: json['isApproved'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'type': type,
      'description': description,
      'location': location != null
          ? {
              'address': location!.address,
              'city': location!.city,
              'postalCode': location!.postalCode,
              'country': location!.country,
              'coordinates': location!.coordinates != null
                  ? {
                      'type': 'Point',
                      'coordinates': [
                        location!.coordinates!.longitude,
                        location!.coordinates!.latitude,
                      ],
                    }
                  : null,
            }
          : null,
      'priceRange': priceRange,
      'menu': menu
          .map((item) => {
                'name': item.name,
                'price': item.price,
              })
          .toList(),
      'images': images,
      'owner': owner,
      'reviews': reviews, // List of review IDs
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
      'rating': rating,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        description,
        location,
        priceRange,
        menu,
        images,
        owner,
        reviews,
        isApproved,
        createdAt,
        rating,
      ];

  @override
  String toString() {
    return 'StoreModel(id: $id, name: $name, type: $type, description: $description, location: $location, '
        'priceRange: $priceRange, menu: $menu, images: $images, owner: $owner, reviews: $reviews, isApproved: $isApproved, createdAt: $createdAt, rating: $rating)';
  }
}