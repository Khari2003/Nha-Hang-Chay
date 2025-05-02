import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/auth.dart';
import '../../../domain/usecases/auth/login.dart';
import '../../../domain/usecases/auth/register.dart';
import '../../../domain/usecases/auth/forgotPassword.dart';
import '../../../domain/usecases/auth/verifyOtp.dart';
import '../../../domain/usecases/auth/resetPassword.dart';

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

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  Auth? get auth => _auth;
  bool get isGuest => _isGuest;

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

  void setGuestMode() {
    _isGuest = true;
    _auth = null;
    notifyListeners();
  }
}