// ignore_for_file: file_names

import '../../domain/entities/store.dart';
import '../../domain/entities/location.dart';

class StoreModel extends Store {
  StoreModel({
    required super.id,
    required super.name,
    required super.address,
    required super.coordinates,
    super.category,
    super.phoneNumber,
    super.website,
    super.priceLevel,
    super.openingHours,
    super.imageURL,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['_id'],
      name: json['name'],
      address: json['address'],
      coordinates: Location(
        latitude: json['coordinates']['lat'],
        longitude: json['coordinates']['lng'],
      ),
      category: json['category'],
      phoneNumber: json['phoneNumber'],
      website: json['website'],
      priceLevel: json['priceLevel'],
      openingHours: json['openingHours'],
      imageURL: json['imageURL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
      'coordinates': {
        'lat': coordinates.latitude,
        'lng': coordinates.longitude,
      },
      'category': category,
      'phoneNumber': phoneNumber,
      'website': website,
      'priceLevel': priceLevel,
      'openingHours': openingHours,
      'imageURL': imageURL,
    };
  }
}