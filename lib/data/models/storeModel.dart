// ignore_for_file: file_names

import 'package:equatable/equatable.dart';
import 'package:my_app/domain/entities/location.dart';
import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/domain/entities/store.dart';

class StoreModel extends Store with EquatableMixin {
  StoreModel({
    required super.id,
    required super.name,
    super.description,
    super.location,
    required super.cuisine,
    required super.priceRange,
    required super.dietaryOptions,
    required super.images,
    super.owner,
    super.reviews,
    super.isApproved = false,
    required super.createdAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    Coordinates? coordinates;
    if (json['location']?['coordinates']?['coordinates'] != null) {
      // Định dạng GeoJSON
      coordinates = Coordinates(
        longitude: (json['location']['coordinates']['coordinates'][0] as num).toDouble(),
        latitude: (json['location']['coordinates']['coordinates'][1] as num).toDouble(),
      );
    } else if (json['location']?['lat'] != null && json['location']?['lon'] != null) {
      // Định dạng lat/lon
      coordinates = Coordinates(
        latitude: double.parse(json['location']['lat'].toString()),
        longitude: double.parse(json['location']['lon'].toString()),
      );
    }

    return StoreModel(
      id: json['_id'] as String?,
      name: json['name'] as String,
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
      cuisine: List<String>.from(json['cuisine'] ?? []),
      priceRange: json['priceRange'] as String? ?? '\$',
      dietaryOptions: List<String>.from(json['dietaryOptions'] ?? []),
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
      'cuisine': cuisine,
      'priceRange': priceRange,
      'dietaryOptions': dietaryOptions,
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
        description,
        location,
        cuisine,
        priceRange,
        dietaryOptions,
        images,
        owner,
        reviews,
        isApproved,
        createdAt,
      ];

  @override
  String toString() {
    return 'StoreModel(id: $id, name: $name, description: $description, location: $location, '
        'cuisine: $cuisine, priceRange: $priceRange, dietaryOptions: $dietaryOptions, '
        'images: $images, owner: $owner, reviews: $reviews, isApproved: $isApproved, createdAt: $createdAt)';
  }
}