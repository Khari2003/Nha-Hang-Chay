import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/domain/entities/location.dart';

class LocationModel extends Location {
  LocationModel({
    required super.address,
    required super.city,
    required super.postalCode,
    required super.country,
    required double latitude,
    required double longitude,
  }) : super(
          coordinates: Coordinates(latitude: latitude, longitude: longitude),
        );

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      address: json['address'],
      city: json['city'],
      postalCode: json['postalCode'] ?? '',
      country: json['country'],
      latitude: double.parse(json['lat']),
      longitude: double.parse(json['lon']),
    );
  }
}