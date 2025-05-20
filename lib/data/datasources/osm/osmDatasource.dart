// ignore_for_file: file_names

import 'package:http/http.dart' as http;
import 'package:my_app/core/errors/exceptions.dart';
import 'dart:convert';

import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/domain/entities/searchResult.dart';

abstract class OSMDataSource {
  Future<List<SearchResult>> searchPlaces(String query);
  Future<SearchResult> reverseGeocode(Coordinates coordinates);
}

class OSMDataSourceImpl implements OSMDataSource {
  @override
  Future<List<SearchResult>> searchPlaces(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$query&addressdetails=1&countrycodes=vn'),
      headers: {'User-Agent': 'my_app'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) {
        final addressDetails = item['address'] ?? {};
        return SearchResult(
          name: item['display_name'] ?? '',
          coordinates: Coordinates(
            latitude: double.parse(item['lat']),
            longitude: double.parse(item['lon']),
          ),
          address: addressDetails['road'] ?? addressDetails['house_number'] ?? '',
          city: addressDetails['city'] ?? addressDetails['town'] ?? addressDetails['village'] ?? '',
          country: addressDetails['country'] ?? '',
          type: item['type'] ?? '',
        );
      }).toList();
    } else {
      throw ServerException('Failed to search places: ${response.statusCode}');
    }
  }

  @override
  Future<SearchResult> reverseGeocode(Coordinates coordinates) async {
    final response = await http.get(
      Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${coordinates.latitude}&lon=${coordinates.longitude}&addressdetails=1&countrycodes=vn'),
      headers: {'User-Agent': 'my_app'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final addressDetails = data['address'] ?? {};
      return SearchResult(
        name: data['display_name'] ?? '',
        coordinates: Coordinates(
          latitude: double.parse(data['lat']),
          longitude: double.parse(data['lon']),
        ),
        address: addressDetails['road'] ?? addressDetails['house_number'] ?? '',
        city: addressDetails['city'] ?? addressDetails['town'] ?? addressDetails['village'] ?? '',
        country: addressDetails['country'] ?? '',
        type: data['type'] ?? 'point',
      );
    } else {
      throw ServerException('Failed to reverse geocode: ${response.statusCode}');
    }
  }
}