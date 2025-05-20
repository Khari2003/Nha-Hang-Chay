// features/data/models/searchResultModel.dart
import 'package:my_app/domain/entities/searchResult.dart';
import 'package:my_app/domain/entities/coordinates.dart';

class SearchResultModel extends SearchResult {
  SearchResultModel({
    required super.name,
    required double latitude,
    required double longitude,
    required super.address,
    required super.city,
    required super.country,
    required super.type,
  }) : super(
          coordinates: Coordinates(latitude: latitude, longitude: longitude),
        );

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      name: json['name'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      type: json['type'],
      latitude: double.parse(json['lat']),
      longitude: double.parse(json['lon']),
    );
  }
}