// ignore_for_file: file_names

import 'package:http/http.dart' as http;
import 'package:my_app/core/errors/exceptions.dart';
import 'dart:convert';

import 'package:my_app/data/models/searchResultModel.dart';

abstract class OSMDataSource {
  Future<List<SearchResultModel>> searchPlaces(String query);
}

class OSMDataSourceImpl implements OSMDataSource {
  @override
  Future<List<SearchResultModel>> searchPlaces(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$query&addressdetails=5&countrycodes=vn'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => SearchResultModel(
            name: item['display_name'] ?? '',
            latitude: double.parse(item['lat']),
            longitude: double.parse(item['lon']),
            type: item['type'] ?? '',
          )).toList();
    } else {
      throw ServerException('Failed to search places: ${response.statusCode}');
    }
  }
}