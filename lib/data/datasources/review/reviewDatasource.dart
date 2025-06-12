// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/reviewModel.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/core/constants/apiEndpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Interface định nghĩa các phương thức để tương tác với dữ liệu đánh giá từ API
abstract class ReviewDataSource {
  // Gửi đánh giá mới cho cửa hàng
  Future<ReviewModel> leaveReview({
    required String storeId,
    required int rating,
    String? comment,
    List<String> imagePaths,
    required String token,
  });

  // Lấy danh sách đánh giá của một cửa hàng theo trang
  Future<List<ReviewModel>> getStoreReviews({
    required String storeId,
    required int page,
    required String token,
  });
}

// Lớp triển khai ReviewDataSource sử dụng HTTP client
class ReviewDataSourceImpl implements ReviewDataSource {
  final http.Client client; // HTTP client để gửi yêu cầu

  ReviewDataSourceImpl(this.client);

  // Lấy access token từ SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  @override
  Future<ReviewModel> leaveReview({
    required String storeId,
    required int rating,
    String? comment,
    List<String> imagePaths = const [],
    required String token,
  }) async {
    try {
      // Kiểm tra token hợp lệ
      final currentToken = await _getToken();
      if (currentToken == null || currentToken != token) {
        throw ServerException('Không tìm thấy hoặc token không hợp lệ');
      }

      // Kiểm tra điểm số hợp lệ
      if (rating < 1 || rating > 5) {
        throw ServerException('Điểm số phải từ 1 đến 5');
      }

      // Tạo request multipart để gửi đánh giá kèm hình ảnh
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiEndpoints.stores}/$storeId/reviews'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';
      request.fields['rating'] = rating.toString();
      if (comment != null && comment.trim().isNotEmpty) {
        request.fields['comment'] = comment.trim(); // Trim comment để khớp với backend
      }

      // Thêm các tệp hình ảnh vào request (tối đa 5)
      if (imagePaths.length > 5) {
        throw ServerException('Chỉ được tải lên tối đa 5 hình ảnh');
      }
      for (var path in imagePaths) {
        request.files.add(await http.MultipartFile.fromPath('images', path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('Phản hồi gửi đánh giá: ${response.statusCode} - $responseBody');

      // Kiểm tra phản hồi từ server
      if (response.statusCode == 201) {
        return ReviewModel.fromJson(jsonDecode(responseBody));
      } else if (response.statusCode == 404) {
        throw ServerException('Nhà hàng hoặc người dùng không tìm thấy');
      } else {
        final error = jsonDecode(responseBody);
        throw ServerException(error['message'] ?? 'Lỗi server (Mã trạng thái ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Lỗi trong yêu cầu HTTP: $e');
      throw ServerException(e is ServerException ? e.message : 'Gửi đánh giá thất bại: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getStoreReviews({
    required String storeId,
    required int page,
    required String token,
  }) async {
    try {
      // Kiểm tra token hợp lệ
      final currentToken = await _getToken();
      if (currentToken == null || currentToken != token) {
        throw ServerException('Không tìm thấy hoặc token không hợp lệ');
      }

      // Gửi yêu cầu GET để lấy danh sách đánh giá
      final response = await client.get(
        Uri.parse('${ApiEndpoints.stores}/$storeId/reviews?page=$page'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Phản hồi lấy đánh giá: ${response.statusCode} - ${response.body}');

      // Kiểm tra phản hồi từ server
      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        return json.map((data) => ReviewModel.fromJson(data)).toList();
      } else if (response.statusCode == 404) {
        throw ServerException('Nhà hàng không tìm thấy');
      } else {
        final error = jsonDecode(response.body);
        throw ServerException(error['message'] ?? 'Lỗi server (Mã trạng thái ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Lỗi trong yêu cầu HTTP: $e');
      throw ServerException(e is ServerException ? e.message : 'Lấy danh sách đánh giá thất bại: $e');
    }
  }
}