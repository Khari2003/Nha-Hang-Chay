// authViewModel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../core/errors/failures.dart';
import '../../../domain/entities/auth.dart';
import '../../../domain/usecases/auth/login.dart';
import '../../../domain/usecases/auth/register.dart';
import '../../../domain/usecases/auth/forgotPassword.dart';
import '../../../domain/usecases/auth/verifyOtp.dart';
import '../../../domain/usecases/auth/resetPassword.dart';
import 'package:my_app/core/constants/apiEndpoints.dart';

class AuthViewModel extends ChangeNotifier {
  final Login loginUseCase;
  final Register registerUseCase;
  final ForgotPassword forgotPasswordUseCase;
  final VerifyOtp verifyOtpUseCase;
  final ResetPassword resetPasswordUseCase;

  AuthViewModel({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.forgotPasswordUseCase,
    required this.verifyOtpUseCase,
    required this.resetPasswordUseCase,
  });

  String? _errorMessage;
  bool _isLoading = false;
  Auth? _auth;
  bool _isGuest = false;
  String? _userEmail;
  String? _userName;
  bool _rememberMe = false;

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  Auth? get auth => _auth;
  bool get isGuest => _isGuest;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  bool get rememberMe => _rememberMe;

  // Load saved user data from SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('userEmail');
    _userName = prefs.getString('userName');
    _isGuest = prefs.getBool('isGuest') ?? false;
    _rememberMe = prefs.getBool('rememberMe') ?? false;
    print('Loaded from SharedPreferences:');
    print('userEmail: $_userEmail');
    print('userName: $_userName');
    print('isGuest: $_isGuest');
    print('rememberMe: $_rememberMe');
    print('accessToken: ${prefs.getString('accessToken')}');
    print('refreshToken: ${prefs.getString('refreshToken')}');
    if (_rememberMe && _userEmail != null && prefs.getString('accessToken') != null) {
      await verifyToken();
    }
    notifyListeners();
  }

  Future<void> verifyToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      print('Verifying token: $accessToken');
      if (accessToken == null) {
        print('No access token found');
        await clearUserData();
        return;
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.verifyToken),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'accessToken': accessToken}),
      );

      print('VerifyToken response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['valid'] == true) {
          _auth = Auth(
            id: json['user']['_id'],
            name: json['user']['name'],
            email: json['user']['email'],
            isAdmin: json['user']['isAdmin'],
            accessToken: accessToken,
            refreshToken: prefs.getString('refreshToken'),
          );
          _userEmail = json['user']['email'];
          _userName = json['user']['name'];
          _isGuest = false;
          print('Token valid, user: $_userEmail');
        } else {
          print('Token invalid, trying to refresh');
          await refreshToken();
        }
      } else if (response.statusCode == 401) {
        print('Access token expired, trying to refresh');
        await refreshToken();
      } else {
        print('VerifyToken failed: ${response.statusCode}');
        await clearUserData();
      }
    } catch (e) {
      print('VerifyToken error: $e');
      await clearUserData();
    }
    notifyListeners();
  }

  // Refresh token if access token is expired
  Future<void> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');
      print('Refreshing token with refreshToken: $refreshToken');
      if (refreshToken == null) {
        print('No refresh token found');
        await clearUserData();
        return;
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.refreshToken),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      print('RefreshToken response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final newAccessToken = json['accessToken'];
        final newRefreshToken = json['refreshToken'];
        _auth = Auth(
          id: _auth?.id ?? json['user']['_id'],
          name: _auth?.name ?? json['user']['name'],
          email: _auth?.email ?? json['user']['email'],
          isAdmin: _auth?.isAdmin ?? json['user']['isAdmin'],
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        await prefs.setString('accessToken', newAccessToken);
        await prefs.setString('refreshToken', newRefreshToken ?? '');
        _userEmail = _auth!.email;
        _userName = _auth!.name;
        _isGuest = false;
        print('Token refreshed successfully, user: $_userEmail, newAccessToken: $newAccessToken');
      } else {
        print('Refresh token failed: ${response.statusCode}');
        await clearUserData();
      }
    } catch (e) {
      print('RefreshToken error: $e');
      await clearUserData();
    }
    notifyListeners();
  }

  Future<void> login(String email, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _auth = await loginUseCase(LoginParams(email, password));
      _isGuest = false;
      _rememberMe = rememberMe;
      if (_auth?.accessToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', _auth!.accessToken!);
        await prefs.setString('refreshToken', _auth!.refreshToken ?? '');
        await prefs.setString('userEmail', email);
        await prefs.setString('userName', _auth!.name ?? '');
        await prefs.setBool('isGuest', false);
        await prefs.setBool('rememberMe', rememberMe);
        _userEmail = email;
        _userName = _auth!.name;
        print('Login successful - accessToken: ${prefs.getString('accessToken')}');
        print('Login successful - refreshToken: ${prefs.getString('refreshToken')}');
        print('Login successful - userEmail: ${prefs.getString('userEmail')}');
        print('Login successful - userName: ${prefs.getString('userName')}');
        print('Login successful - isGuest: ${prefs.getBool('isGuest')}');
        print('Login successful - rememberMe: ${prefs.getBool('rememberMe')}');
      }
    } catch (e) {
      _errorMessage = e is ServerFailure ? e.message : 'Lỗi xảy ra khi đăng nhập';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password, String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _auth = await registerUseCase(RegisterParams(name, email, password, phone));
      _isGuest = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', email);
      await prefs.setString('userName', name);
      await prefs.setBool('isGuest', false);
      await prefs.setBool('rememberMe', false);
      _userEmail = email;
      _userName = name;
    } catch (e) {
      _errorMessage = e is ServerFailure ? e.message : 'Lỗi xảy ra khi đăng kí';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _auth = await forgotPasswordUseCase(ForgotPasswordParams(email));
    } catch (e) {
      _errorMessage = e is ServerFailure ? e.message : 'Lỗi xảy ra khi quên mật khẩu';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _auth = await verifyOtpUseCase(VerifyOtpParams(email, otp));
    } catch (e) {
      _errorMessage = e is ServerFailure ? e.message : 'Lỗi xảy ra khi xác thực OTP';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _auth = await resetPasswordUseCase(ResetPasswordParams(email, newPassword));
    } catch (e) {
      _errorMessage = e is ServerFailure ? e.message : 'Lỗi xảy ra khi đặt lại mật khẩu';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken != null) {
        final response = await http.post(
          Uri.parse(ApiEndpoints.logout),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );

        print('Logout response: ${response.statusCode}');
        if (response.statusCode != 200 && response.statusCode != 204) {
          throw ServerFailure('Đăng xuất thất bại: ${response.reasonPhrase}');
        }
      }

      await clearUserData();
      print('Sau khi đăng xuất - accessToken: ${prefs.getString('accessToken')}');
      print('Sau khi đăng xuất - rememberMe: ${prefs.getBool('rememberMe')}');
    } catch (e) {
      _errorMessage = e is ServerFailure ? e.message : 'Lỗi xảy ra khi đăng xuất';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    await prefs.remove('isGuest');
    await prefs.setBool('rememberMe', false);
    _auth = null;
    _isGuest = false;
    _userEmail = null;
    _userName = null;
    _rememberMe = false;
    notifyListeners();
  }

  void setGuestMode() {
    _isGuest = true;
    _auth = null;
    _userEmail = null;
    _userName = null;
    _rememberMe = false;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isGuest', true);
      prefs.setBool('rememberMe', false);
      prefs.remove('userEmail');
      prefs.remove('userName');
    });
    notifyListeners();
  }
}