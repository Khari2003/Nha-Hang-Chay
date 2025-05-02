import '../../entities/auth.dart';
import '../../repositories/authRepository.dart';
import '../usecase.dart';

class ResetPassword implements UseCase<Auth, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPassword(this.repository);

  @override
  Future<Auth> call(ResetPasswordParams params) async {
    // Có thể thêm validation: newPassword hợp lệ
    return await repository.resetPassword(params.email, params.newPassword);
  }
}

class ResetPasswordParams {
  final String email;
  final String newPassword;

  ResetPasswordParams(this.email, this.newPassword);
}