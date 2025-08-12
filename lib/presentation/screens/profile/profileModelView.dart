// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/apiEndpoints.dart';
import '../../../core/errors/failures.dart';
import '../auth/authViewModel.dart';

// ViewModel quản lý logic cho màn hình Profile
class ProfileViewModel extends ChangeNotifier {
  // Lưu thông tin profile người dùng từ API
  Map<String, dynamic>? _userProfile;
  // Trạng thái đang tải dữ liệu
  bool _isLoading = false;
  // Lưu thông báo lỗi (nếu có)
  String? _errorMessage;

  // Getter để truy cập thông tin profile
  Map<String, dynamic>? get userProfile => _userProfile;
  // Getter để kiểm tra trạng thái tải
  bool get isLoading => _isLoading;
  // Getter để truy cập thông báo lỗi
  String? get errorMessage => _errorMessage;

  // Lấy thông tin profile từ API /users/:id
  Future<void> fetchUserProfile(BuildContext context) async {
    // Lấy AuthViewModel để truy cập id và accessToken
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    // Kiểm tra thông tin xác thực
    if (authViewModel.auth?.id == null || authViewModel.auth?.accessToken == null) {
      _errorMessage = 'Không tìm thấy thông tin xác thực';
      notifyListeners();
      return;
    }

    // Bắt đầu tải dữ liệu
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Gọi API để lấy thông tin profile
      final response = await http.get(
        Uri.parse('${ApiEndpoints.userById}${authViewModel.auth!.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authViewModel.auth!.accessToken}',
        },
      );

      // Xử lý phản hồi từ API
      if (response.statusCode == 200) {
        _userProfile = jsonDecode(response.body);
      } else {
        _errorMessage = 'Lỗi khi lấy thông tin profile: ${response.reasonPhrase}';
      }
    } catch (e) {
      // Xử lý lỗi (ServerFailure hoặc lỗi khác)
      _errorMessage = e is ServerFailure ? e.message : 'Lỗi xảy ra khi lấy profile';
    } finally {
      // Kết thúc tải dữ liệu
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật thông tin profile (name, phone) qua API /users/:id
  Future<void> updateUserProfile(BuildContext context, {String? name, String? phone}) async {
    // Lấy AuthViewModel để truy cập id và accessToken
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    // Kiểm tra thông tin xác thực
    if (authViewModel.auth?.id == null || authViewModel.auth?.accessToken == null) {
      _errorMessage = 'Không tìm thấy thông tin xác thực';
      notifyListeners();
      return;
    }

    // Bắt đầu tải dữ liệu
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Gọi API để cập nhật thông tin profile
      final response = await http.put(
        Uri.parse('${ApiEndpoints.userById}${authViewModel.auth!.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authViewModel.auth!.accessToken}',
        },
        body: jsonEncode({
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
        }),
      );

      // Xử lý phản hồi từ API
      if (response.statusCode == 200) {
        _userProfile = jsonDecode(response.body);
        // Lưu tên mới vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        if (name != null) await prefs.setString('userName', name);
      } else {
        _errorMessage = 'Lỗi khi cập nhật profile: ${response.reasonPhrase}';
      }
    } catch (e) {
      // Xử lý lỗi (ServerFailure hoặc lỗi khác)
      _errorMessage = e is ServerFailure ? e.message : 'Lỗi xảy ra khi cập nhật profile';
    } finally {
      // Kết thúc tải dữ liệu
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thực hiện đăng xuất
  Future<void> logout(BuildContext context) async {
    // Gọi phương thức logout từ AuthViewModel
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.logout();
  }
}