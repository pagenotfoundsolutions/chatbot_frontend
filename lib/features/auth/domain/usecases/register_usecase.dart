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
    if (params.email.trim().isEmpty || !params.email.contains('@')) {
      return Future.value(const Left(ValidationFailure('Please enter a valid email address')));
    }
    if (params.password.length < 8) {
      return Future.value(const Left(ValidationFailure('Password must be at least 8 characters long')));
    }
    return repository.register(params.email, params.password);
  }
}
