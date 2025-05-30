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
    super.owner,
    super.reviews,
    super.isApproved = false,
    required super.createdAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    Coordinates? coordinates;
    if (json['location']?['coordinates']?['coordinates'] != null) {
      coordinates = Coordinates(
        longitude: (json['location']['coordinates']['coordinates'][0] as num).toDouble(),
        latitude: (json['location']['coordinates']['coordinates'][1] as num).toDouble(),
      );
    }

    return StoreModel(
      id: json['_id'] as String?,
      name: json['name'] as String,
      type: json['type'] as String,
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
                    name: item['name'] as String,
                    price: (item['price'] as num).toDouble(),
                  ))
              .toList() ??
          [],
      images: List<String>.from(json['images'] ?? []),
      owner: json['owner'] as String?,
      reviews: json['reviews'] != null ? List<String>.from(json['reviews']) : null,
      isApproved: json['isApproved'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
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
      'reviews': reviews,
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
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
      ];

  @override
  String toString() {
    return 'StoreModel(id: $id, name: $name, type: $type, description: $description, location: $location, '
        'priceRange: $priceRange, menu: $menu, images: $images, owner: $owner, reviews: $reviews, isApproved: $isApproved, createdAt: $createdAt)';
  }
}