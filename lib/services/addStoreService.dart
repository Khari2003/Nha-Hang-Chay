// ignore_for_file: file_names

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddStoreService {
  static Future<List<Map<String, dynamic>>> fetchAddStores() async {
    final String? apiStore = dotenv.env['API_SERVER'];
    final response = await http.get(Uri.parse('$apiStore/store/createStore'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch stores data');
    }
  }
}