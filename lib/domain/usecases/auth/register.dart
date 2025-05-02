import '../../entities/auth.dart';
import '../../repositories/authRepository.dart';
import '../usecase.dart';

class Register implements UseCase<Auth, RegisterParams> {
  final AuthRepository repository;

  Register(this.repository);

  @override
  Future<Auth> call(RegisterParams params) async {
    // Có thể thêm validation: name, email, password, phone hợp lệ
    return await repository.register(params.name, params.email, params.password, params.phone);
  }
}

class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String phone;

  RegisterParams(this.name, this.email, this.password, this.phone);
}