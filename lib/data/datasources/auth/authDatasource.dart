import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/core/constants/apiEndpoints.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/data/models/authModel.dart';

abstract class AuthDataSource {
  Future<AuthModel> login(String email, String password);
  Future<AuthModel> register(String name, String email, String password, String phone);
  Future<AuthModel> forgotPassword(String email);
  Future<AuthModel> verifyOtp(String email, String otp);
  Future<AuthModel> resetPassword(String email, String newPassword);
}

class AuthDataSourceImpl implements AuthDataSource {
  final http.Client client;

  AuthDataSourceImpl(this.client);

  @override
  Future<AuthModel> login(String email, String password) async {
    final response = await client.post(
      Uri.parse(ApiEndpoints.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return AuthModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(jsonDecode(response.body)['message'] ?? 'Login failed');
    }
  }

  @override
  Future<AuthModel> register(String name, String email, String password, String phone) async {
    final response = await client.post(
      Uri.parse(ApiEndpoints.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );

    if (response.statusCode == 201) {
      return AuthModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(jsonDecode(response.body)['message'] ?? 'Registration failed');
    }
  }

  @override
  Future<AuthModel> forgotPassword(String email) async {
    final response = await client.post(
      Uri.parse(ApiEndpoints.forgotPassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return AuthModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(jsonDecode(response.body)['message'] ?? 'Failed to send OTP');
    }
  }

  @override
  Future<AuthModel> verifyOtp(String email, String otp) async {
    final response = await client.post(
      Uri.parse(ApiEndpoints.verifyOtp),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      return AuthModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(jsonDecode(response.body)['message'] ?? 'Invalid OTP');
    }
  }

  @override
  Future<AuthModel> resetPassword(String email, String newPassword) async {
    final response = await client.post(
      Uri.parse(ApiEndpoints.resetPassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'newPassword': newPassword}),
    );

    if (response.statusCode == 200) {
      return AuthModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(jsonDecode(response.body)['message'] ?? 'Failed to reset password');
    }
  }
}