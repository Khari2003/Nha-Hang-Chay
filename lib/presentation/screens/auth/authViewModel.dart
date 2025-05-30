// authViewModel.dart
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

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  Auth? get auth => _auth;
  bool get isGuest => _isGuest;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  // Load saved user data from SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('userEmail');
    _userName = prefs.getString('userName');
    _isGuest = prefs.getBool('isGuest') ?? false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _auth = await loginUseCase(LoginParams(email, password));
      _isGuest = false;
      if (_auth?.accessToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', _auth!.accessToken!);
        await prefs.setString('refreshToken', _auth!.refreshToken ?? '');
        // Save additional user info
        await prefs.setString('userEmail', email);
        await prefs.setString('userName', _auth!.name ?? ''); // Assuming Auth entity has a name field
        await prefs.setBool('isGuest', false);
        _userEmail = email;
        _userName = _auth!.name;
      }
    } catch (e) {
      _errorMessage = e is ServerFailure ? e.message : 'An error occurred';
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
      // Save user info after registration
      await prefs.setString('userEmail', email);
      await prefs.setString('userName', name);
      await prefs.setBool('isGuest', false);
      _userEmail = email;
      _userName = name;
    } catch (e) {
      _errorMessage = e is ServerFailure ? e.message : 'An error occurred';
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
      _errorMessage = e is ServerFailure ? e.message : 'An error occurred';
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
      _errorMessage = e is ServerFailure ? e.message : 'An error occurred';
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
      _errorMessage = e is ServerFailure ? e.message : 'An error occurred';
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

        if (response.statusCode != 200 && response.statusCode != 204) {
          throw ServerFailure('Logout failed: ${response.reasonPhrase}');
        }
      }

      // Clear all user data
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      await prefs.remove('userEmail');
      await prefs.remove('userName');
      await prefs.remove('isGuest');
      _auth = null;
      _isGuest = false;
      _userEmail = null;
      _userName = null;
    } catch (e) {
      _errorMessage = e is ServerFailure ? e.message : 'An error occurred during logout';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setGuestMode() {
    _isGuest = true;
    _auth = null;
    _userEmail = null;
    _userName = null;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isGuest', true);
      prefs.remove('userEmail');
      prefs.remove('userName');
    });
    notifyListeners();
  }
}