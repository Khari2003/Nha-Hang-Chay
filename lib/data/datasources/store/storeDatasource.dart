// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/core/errors/exceptions.dart';
import 'dart:convert';
import 'package:my_app/data/models/storeModel.dart';
import 'package:my_app/core/constants/apiEndpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class StoreDataSource {
  Future<List<StoreModel>> getStores();
  Future<StoreModel> createStore(StoreModel store);
}

class StoreDataSourceImpl implements StoreDataSource {
  final http.Client client;

  StoreDataSourceImpl(this.client);

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  @override
  Future<List<StoreModel>> getStores() async {
    try {
      final token = await _getToken();
      final response = await client.get(
        Uri.parse(ApiEndpoints.stores),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StoreModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to fetch stores: Status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in HTTP request: $e');
      throw ServerException('Failed to fetch stores: $e');
    }
  }

  @override
  Future<StoreModel> createStore(StoreModel store) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException('No access token found');
      }

      final response = await client.post(
        Uri.parse(ApiEndpoints.createStore),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(store.toJson()),
      );

      if (response.statusCode == 201) {
        final dynamic data = json.decode(response.body);
        return StoreModel.fromJson(data);
      } else {
        throw ServerException('Failed to create store: Status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in HTTP request: $e');
      throw ServerException('Failed to create store: $e');
    }
  }
}