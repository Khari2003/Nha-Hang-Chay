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
  Future<StoreModel> updateStore(String id, StoreModel store);
  Future<void> deleteStore(String id);
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
      if (token == null) {
        throw ServerException('No access token found');
      }
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
        final errorMessage = _extractErrorMessage(response);
        throw ServerException(errorMessage);
      }
    } catch (e) {
      debugPrint('Error in HTTP request: $e');
      throw ServerException(e is ServerException ? e.message : 'Failed to fetch stores: $e');
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

      debugPrint('Create store response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        final dynamic data = json.decode(response.body);
        return StoreModel.fromJson(data);
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw ServerException(errorMessage);
      }
    } catch (e) {
      debugPrint('Error in HTTP request: $e');
      throw ServerException(e is ServerException ? e.message : 'Failed to create store: $e');
    }
  }

  @override
  Future<StoreModel> updateStore(String id, StoreModel store) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException('No access token found');
      }

      final response = await client.put(
        Uri.parse('${ApiEndpoints.updateStore}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(store.toJson()),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return StoreModel.fromJson(data);
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw ServerException(errorMessage);
      }
    } catch (e) {
      debugPrint('Error in HTTP request: $e');
      throw ServerException(e is ServerException ? e.message : 'Failed to update store: $e');
    }
  }

  @override
  Future<void> deleteStore(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException('No access token found');
      }

      final response = await client.delete(
        Uri.parse('${ApiEndpoints.deleteStore}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorMessage = _extractErrorMessage(response);
        throw ServerException(errorMessage);
      }
    } catch (e) {
      debugPrint('Error in HTTP request: $e');
      throw ServerException(e is ServerException ? e.message : 'Failed to delete store: $e');
    }
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      return json['message'] ?? json['error'] ?? 'Server error (Status ${response.statusCode})';
    } catch (e) {
      return 'Unable to parse server response (Status ${response.statusCode})';
    }
  }
}