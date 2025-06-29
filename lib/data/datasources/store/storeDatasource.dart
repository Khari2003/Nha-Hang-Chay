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
  Future<StoreModel> createStore(StoreModel store, {List<String> imagePaths = const []});
  Future<StoreModel> updateStore(String id, StoreModel store, {List<String> imagePaths = const []});
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
  @override
Future<StoreModel> createStore(StoreModel store, {List<String> imagePaths = const []}) async {
    try {
        final token = await _getToken();
        if (token == null) {
            throw ServerException('Không tìm thấy access token');
        }

        if (store.location?.coordinates == null) {
            throw ServerException('Cần tọa độ cho vị trí cửa hàng');
        }

        if (imagePaths.length > 10) {
            throw ServerException('Chỉ được tải lên tối đa 10 hình ảnh');
        }

        var request = http.MultipartRequest(
            'POST',
            Uri.parse(ApiEndpoints.createStore),
        );
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Content-Type'] = 'multipart/form-data';

        final storeData = store.toJson();
        storeData['reviews'] = storeData['reviews'] ?? []; // Đảm bảo reviews là mảng rỗng
        storeData.remove('images'); // Hình ảnh sẽ được gửi dưới dạng file
        storeData.remove('_id'); // Xóa _id khi tạo mới
        storeData.remove('rating'); // Rating được backend tính toán
        storeData.remove('createdAt'); // CreatedAt được backend đặt

        debugPrint('Store data: ${jsonEncode(storeData)}');

        // Xử lý các trường
        request.fields['name'] = storeData['name']?.toString() ?? '';
        request.fields['type'] = storeData['type']?.toString() ?? '';
        request.fields['priceRange'] = storeData['priceRange']?.toString() ?? 'Moderate';
        if (storeData['description'] != null) {
            request.fields['description'] = storeData['description'].toString();
        }
        if (storeData['location'] != null) {
            request.fields['location'] = jsonEncode(storeData['location']);
        }
        request.fields['menu'] = jsonEncode(storeData['menu'] ?? []);
        request.fields['reviews'] = jsonEncode([]); // Gửi mảng rỗng rõ ràng
        if (storeData['owner'] != null) {
            request.fields['owner'] = storeData['owner'].toString();
        }
        request.fields['isApproved'] = storeData['isApproved'].toString();

        for (var path in imagePaths) {
            request.files.add(await http.MultipartFile.fromPath('images', path));
        }

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        debugPrint('Phản hồi tạo cửa hàng: ${response.statusCode} - $responseBody');

        if (response.statusCode == 200 || response.statusCode == 201) {
            final jsonResponse = jsonDecode(responseBody);
            return StoreModel.fromJson(jsonResponse);
        } else {
            final errorMessage = _extractErrorMessageFromBody(responseBody);
            throw ServerException(errorMessage);
        }
    } catch (e) {
        debugPrint('Lỗi trong yêu cầu HTTP createStore: $e');
        throw ServerException(e is ServerException ? e.message : 'Tạo cửa hàng thất bại: $e');
    }
}

  @override
  Future<StoreModel> updateStore(String id, StoreModel store, {List<String> imagePaths = const []}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException('Không tìm thấy access token');
      }

      if (store.location?.coordinates == null) {
        throw ServerException('Cần tọa độ cho vị trí cửa hàng');
      }

      if (imagePaths.length > 10) {
        throw ServerException('Chỉ được tải lên tối đa 10 hình ảnh');
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiEndpoints.stores}/$id'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      final storeData = store.toJson();
      storeData['reviews'] = storeData['reviews'] ?? []; // Ensure reviews is an empty list
      storeData.remove('images'); // Images will be sent as files
      storeData.remove('_id'); // Remove _id for update
      storeData.remove('rating'); // Rating is calculated by backend
      storeData.remove('createdAt'); // CreatedAt is set by backend

      // Handle complex fields by encoding them as JSON strings
      request.fields['name'] = storeData['name']?.toString() ?? '';
      request.fields['type'] = storeData['type']?.toString() ?? '';
      request.fields['priceRange'] = storeData['priceRange']?.toString() ?? 'Moderate';
      if (storeData['description'] != null) {
        request.fields['description'] = storeData['description'].toString();
      }
      if (storeData['location'] != null) {
        request.fields['location'] = jsonEncode(storeData['location']);
      }
      request.fields['menu'] = jsonEncode(storeData['menu'] ?? []);
      request.fields['reviews'] = jsonEncode(storeData['reviews']);
      if (storeData['owner'] != null) {
        request.fields['owner'] = storeData['owner'].toString();
      }
      request.fields['isApproved'] = storeData['isApproved'].toString();

      for (var path in imagePaths) {
        request.files.add(await http.MultipartFile.fromPath('images', path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('Phản hồi cập nhật cửa hàng: ${response.statusCode} - $responseBody');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(responseBody);
        return StoreModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw ServerException('Chưa xác thực');
      } else if (response.statusCode == 403) {
        throw ServerException('Không có quyền cập nhật cửa hàng');
      } else if (response.statusCode == 404) {
        throw ServerException('Không tìm thấy cửa hàng');
      } else {
        final errorMessage = _extractErrorMessageFromBody(responseBody);
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

  String _extractErrorMessageFromBody(String responseBody) {
    try {
      final json = jsonDecode(responseBody);
      return json['message'] ?? json['error'] ?? 'Lỗi server';
    } catch (e) {
      return 'Không thể phân tích phản hồi server';
    }
  }
}