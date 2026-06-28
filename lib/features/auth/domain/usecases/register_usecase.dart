import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;
  const RegisterParams({required this.email, required this.password});
}

class RegisterUseCase implements UseCase<void, RegisterParams> {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RegisterParams params) {
    return repository.register(params.email, params.password);
  }
}
