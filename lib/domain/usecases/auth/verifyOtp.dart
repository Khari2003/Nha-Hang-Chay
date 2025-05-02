import '../../entities/auth.dart';
import '../../repositories/authRepository.dart';
import '../usecase.dart';

class VerifyOtp implements UseCase<Auth, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  @override
  Future<Auth> call(VerifyOtpParams params) async {
    // Có thể thêm validation: otp không rỗng
    return await repository.verifyOtp(params.email, params.otp);
  }
}

class VerifyOtpParams {
  final String email;
  final String otp;

  VerifyOtpParams(this.email, this.otp);
}