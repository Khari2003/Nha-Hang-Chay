import '../../entities/auth.dart';
import '../../repositories/authRepository.dart';
import '../usecase.dart';

class Login implements UseCase<Auth, LoginParams> {
  final AuthRepository repository;

  Login(this.repository);

  @override
  Future<Auth> call(LoginParams params) async {
    // Có thể thêm validation: email không rỗng, password hợp lệ
    return await repository.login(params.email, params.password);
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams(this.email, this.password);
}