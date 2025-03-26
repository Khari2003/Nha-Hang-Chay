// ignore_for_file: file_names

import 'package:http/http.dart' as http;
import 'dart:convert';

class OSMService {
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    final response = await http.get(
      Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$query&addressdetails=5'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) {
        return {
          "name": item["display_name"],
          "lat": item["lat"],
          "lon": item["lon"],
          "type": item["type"],
          "address": item["address"] ?? {}, 
        };
      }).toList();
    } else {
      throw Exception('Không thể tìm kiếm địa điểm');
    }
  }
}
