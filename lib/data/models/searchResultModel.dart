// features/data/models/searchResultModel.dart
import 'package:my_app/domain/entities/searchResult.dart';
import 'package:my_app/domain/entities/location.dart';

class SearchResultModel extends SearchResult {
  SearchResultModel({
    required super.name,
    required double latitude,
    required double longitude,
    required super.type,
  }) : super(
          coordinates: Location(latitude: latitude, longitude: longitude),
        );

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      name: json['display_name'] ?? '',
      latitude: double.parse(json['lat']),
      longitude: double.parse(json['lon']),
      type: json['type'] ?? 'unknown',
    );
  }
}