import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/auth.dart';
import '../../domain/repositories/authRepository.dart';
import '../datasources/auth/authDatasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Auth> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw ServerFailure('Email and password cannot be empty');
    }
    try {
      final authModel = await dataSource.login(email, password);
      return Auth(
        id: authModel.id,
        name: authModel.name,
        email: authModel.email,
        isAdmin: authModel.isAdmin,
        accessToken: authModel.accessToken,
        refreshToken: authModel.refreshToken,
      );
    } catch (e) {
      if (e is ServerException) {
        throw ServerFailure(e.message);
      }
      throw ServerFailure('Unknown error during login');
    }
  }

  @override
  Future<Auth> register(String name, String email, String password, String phone) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      throw ServerFailure('All fields are required');
    }
    try {
      final authModel = await dataSource.register(name, email, password, phone);
      return Auth(
        id: authModel.id,
        name: authModel.name,
        email: authModel.email,
      );
    } catch (e) {
      if (e is ServerException) {
        throw ServerFailure(e.message);
      }
      throw ServerFailure('Unknown error during registration');
    }
  }

  @override
  Future<Auth> forgotPassword(String email) async {
    if (email.isEmpty) {
      throw ServerFailure('Email cannot be empty');
    }
    try {
      final authModel = await dataSource.forgotPassword(email);
      return Auth(message: authModel.message);
    } catch (e) {
      if (e is ServerException) {
        throw ServerFailure(e.message);
      }
      throw ServerFailure('Unknown error during forgot password');
    }
  }

  @override
  Future<Auth> verifyOtp(String email, String otp) async {
    if (email.isEmpty || otp.isEmpty) {
      throw ServerFailure('Email and OTP cannot be empty');
    }
    try {
      final authModel = await dataSource.verifyOtp(email, otp);
      return Auth(message: authModel.message);
    } catch (e) {
      if (e is ServerException) {
        throw ServerFailure(e.message);
      }
      throw ServerFailure('Unknown error during OTP verification');
    }
  }

  @override
  Future<Auth> resetPassword(String email, String newPassword) async {
    if (email.isEmpty || newPassword.isEmpty) {
      throw ServerFailure('Email and new password cannot be empty');
    }
    try {
      final authModel = await dataSource.resetPassword(email, newPassword);
      return Auth(message: authModel.message);
    } catch (e) {
      if (e is ServerException) {
        throw ServerFailure(e.message);
      }
      throw ServerFailure('Unknown error during password reset');
    }
  }
}