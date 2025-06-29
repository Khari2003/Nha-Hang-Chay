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
      final response = await client.get(
        Uri.parse(ApiEndpoints.stores),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<dynamic> storeList;
        
        if (data is List<dynamic>) {
          storeList = data;
        } else if (data is Map<String, dynamic> && data['stores'] is List<dynamic>) {
          storeList = data['stores'];
        } else {
          throw ServerException('Định dạng phản hồi không mong đợi: Không phải danh sách cửa hàng');
        }

        return storeList.map((json) => StoreModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw ServerException('Chưa xác thực');
      } else if (response.statusCode == 404) {
        throw ServerException('Không tìm thấy cửa hàng');
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw ServerException(errorMessage);
      }
    } catch (e) {
      debugPrint('Lỗi trong yêu cầu HTTP getStores: $e');
      throw ServerException(e is ServerException ? e.message : 'Lấy danh sách cửa hàng thất bại: $e');
    }
  }

  @override
  Future<StoreModel> createStore(StoreModel store) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException('Không tìm thấy access token');
      }

      if (store.location?.coordinates == null) {
        throw ServerException('Cần tọa độ cho vị trí cửa hàng');
      }

      if (store.images.length > 10) {
        throw ServerException('Chỉ được tải lên tối đa 10 hình ảnh');
      }

      final storeData = store.toJson();
      storeData['reviews'] = storeData['reviews'] ?? [];
      storeData.remove('_id');
      storeData.remove('rating');
      storeData.remove('createdAt');

      debugPrint('Dữ liệu cửa hàng: ${jsonEncode(storeData)}');

      final response = await client.post(
        Uri.parse(ApiEndpoints.createStore),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(storeData),
      );

      debugPrint('Phản hồi tạo cửa hàng: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return StoreModel.fromJson(jsonResponse);
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw ServerException(errorMessage);
      }
    } catch (e) {
      debugPrint('Lỗi trong yêu cầu HTTP createStore: $e');
      throw ServerException(e is ServerException ? e.message : 'Tạo cửa hàng thất bại: $e');
    }
  }

  @override
  Future<StoreModel> updateStore(String id, StoreModel store) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException('Không tìm thấy access token');
      }

      if (store.location?.coordinates == null) {
        throw ServerException('Cần tọa độ cho vị trí cửa hàng');
      }

      if (store.images.length > 10) {
        throw ServerException('Chỉ được tải lên tối đa 10 hình ảnh');
      }

      final storeData = store.toJson();
      storeData['reviews'] = storeData['reviews'] ?? [];
      storeData.remove('_id');
      storeData.remove('rating');
      storeData.remove('createdAt');

      final response = await client.put(
        Uri.parse('${ApiEndpoints.stores}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(storeData),
      );

      debugPrint('Phản hồi cập nhật cửa hàng: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return StoreModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw ServerException('Chưa xác thực');
      } else if (response.statusCode == 403) {
        throw ServerException('Không có quyền cập nhật cửa hàng');
      } else if (response.statusCode == 404) {
        throw ServerException('Không tìm thấy cửa hàng');
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw ServerException(errorMessage);
      }
    } catch (e) {
      debugPrint('Lỗi trong yêu cầu HTTP updateStore: $e');
      throw ServerException(e is ServerException ? e.message : 'Cập nhật cửa hàng thất bại: $e');
    }
  }

  @override
  Future<void> deleteStore(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException('Không tìm thấy access token');
      }

      final response = await client.delete(
        Uri.parse('${ApiEndpoints.stores}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Phản hồi xóa cửa hàng: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw ServerException('Chưa xác thực');
      } else if (response.statusCode == 403) {
        throw ServerException('Không có quyền xóa cửa hàng');
      } else if (response.statusCode == 404) {
        throw ServerException('Không tìm thấy cửa hàng');
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw ServerException(errorMessage);
      }
    } catch (e) {
      debugPrint('Lỗi trong yêu cầu HTTP deleteStore: $e');
      throw ServerException(e is ServerException ? e.message : 'Xóa cửa hàng thất bại: $e');
    }
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      return json['message'] ?? json['error'] ?? 'Lỗi server (Mã trạng thái ${response.statusCode})';
    } catch (e) {
      return 'Không thể phân tích phản hồi server (Mã trạng thái ${response.statusCode})';
    }
  }
}