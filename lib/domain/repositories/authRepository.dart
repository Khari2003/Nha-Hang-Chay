import '../entities/auth.dart';

abstract class AuthRepository {
  Future<Auth> login(String email, String password);
  Future<Auth> register(String name, String email, String password, String phone);
  Future<Auth> forgotPassword(String email);
  Future<Auth> verifyOtp(String email, String otp);
  Future<Auth> resetPassword(String email, String newPassword);
}