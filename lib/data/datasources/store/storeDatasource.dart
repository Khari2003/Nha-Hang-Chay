// ignore_for_file: file_names

import 'package:http/http.dart' as http;
import 'package:my_app/core/errors/exceptions.dart';
import 'dart:convert';

import 'package:my_app/data/models/storeModel.dart';

abstract class StoreDataSource {
  Future<List<StoreModel>> getStores();
}

class StoreDataSourceImpl implements StoreDataSource {
  @override
  Future<List<StoreModel>> getStores() async {
    final response = await http
        .get(Uri.parse('https:/server-morning-forest-197.fly.dev/api/stores'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => StoreModel.fromJson(json)).toList();
    } else {
      throw ServerException('Failed to fetch stores data');
    }
  }
}