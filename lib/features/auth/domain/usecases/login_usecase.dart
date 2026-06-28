import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
}

class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    if (params.email.trim().isEmpty || !params.email.contains('@')) {
      return Future.value(const Left(ValidationFailure('Please enter a valid email address')));
    }
    if (params.password.isEmpty) {
      return Future.value(const Left(ValidationFailure('Password is required')));
    }
    return repository.login(params.email, params.password);
  }
}
