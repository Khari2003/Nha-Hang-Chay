// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/core/errors/exceptions.dart';
import 'dart:convert';
import 'package:my_app/data/models/storeModel.dart';
import 'package:my_app/core/constants/apiEndpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Interface định nghĩa các phương thức để tương tác với dữ liệu cửa hàng
abstract class StoreDataSource {
  Future<List<StoreModel>> getStores(); // Lấy danh sách cửa hàng
  Future<StoreModel> createStore(StoreModel store); // Tạo cửa hàng mới
  Future<StoreModel> updateStore(String id, StoreModel store); // Cập nhật cửa hàng
  Future<void> deleteStore(String id); // Xóa cửa hàng
}

// Lớp triển khai StoreDataSource sử dụng HTTP client
class StoreDataSourceImpl implements StoreDataSource {
  final http.Client client; // HTTP client để gửi yêu cầu

  StoreDataSourceImpl(this.client);

  // Lấy access token từ SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // Lấy danh sách cửa hàng từ API (không yêu cầu token)
  @override
  Future<List<StoreModel>> getStores() async {
    try {
      final response = await client.get(
        Uri.parse(ApiEndpoints.stores),
        headers: {
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
      debugPrint('Lỗi trong yêu cầu HTTP: $e');
      throw ServerException(e is ServerException ? e.message : 'Lấy danh sách cửa hàng thất bại: $e');
    }
  }

  // Tạo cửa hàng mới
  @override
  Future<StoreModel> createStore(StoreModel store) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException('Không tìm thấy access token');
      }

      // Kiểm tra tọa độ cửa hàng
      if (store.location?.coordinates == null) {
        throw ServerException('Cần tọa độ cho vị trí cửa hàng');
      }

      final response = await client.post(
        Uri.parse(ApiEndpoints.createStore),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(store.toJson()),
      );

      debugPrint('Phản hồi tạo cửa hàng: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        final dynamic data = json.decode(response.body);
        return StoreModel.fromJson(data);
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw ServerException(errorMessage);
      }
    } catch (e) {
      debugPrint('Lỗi trong yêu cầu HTTP: $e');
      throw ServerException(e is ServerException ? e.message : 'Tạo cửa hàng thất bại: $e');
    }
  }

  // Cập nhật thông tin cửa hàng
  @override
  Future<StoreModel> updateStore(String id, StoreModel store) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException('Không tìm thấy access token');
      }

      // Kiểm tra tọa độ cửa hàng
      if (store.location?.coordinates == null) {
        throw ServerException('Cần tọa độ cho vị trí cửa hàng');
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
      debugPrint('Lỗi trong yêu cầu HTTP: $e');
      throw ServerException(e is ServerException ? e.message : 'Cập nhật cửa hàng thất bại: $e');
    }
  }

  // Xóa cửa hàng
  @override
  Future<void> deleteStore(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException('Không tìm thấy access token');
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
      debugPrint('Lỗi trong yêu cầu HTTP: $e');
      throw ServerException(e is ServerException ? e.message : 'Xóa cửa hàng thất bại: $e');
    }
  }

  // Trích xuất thông báo lỗi từ phản hồi HTTP
  String _extractErrorMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      return json['message'] ?? json['error'] ?? 'Lỗi server (Mã trạng thái ${response.statusCode})';
    } catch (e) {
      return 'Không thể phân tích phản hồi server (Mã trạng thái ${response.statusCode})';
    }
  }
}