import '../../entities/auth.dart';
import '../../repositories/authRepository.dart';
import '../usecase.dart';

class ForgotPassword implements UseCase<Auth, ForgotPasswordParams> {
  final AuthRepository repository;

  ForgotPassword(this.repository);

  @override
  Future<Auth> call(ForgotPasswordParams params) async {
    // Có thể thêm validation: email hợp lệ
    return await repository.forgotPassword(params.email);
  }
}

class ForgotPasswordParams {
  final String email;

  ForgotPasswordParams(this.email);
}