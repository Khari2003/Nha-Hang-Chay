// ignore_for_file: file_names

import 'dart:convert';
import 'package:http/http.dart' as http;

class TrafficService {
  static Future<List<Map<String, dynamic>>> fetchTrafficData(String cityName) async {
    final String apiUrl =
        'https://secure-mesa-52472-4283a7099f0c.herokuapp.com/traffic/search?name=$cityName';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          // Trích xuất chỉ `confidence` và `coordinates`
          return data.map<Map<String, dynamic>>((item) {
            return {
              'confidence': item['confidence'],
              'coordinates': item['coordinates'],
            };
          }).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
