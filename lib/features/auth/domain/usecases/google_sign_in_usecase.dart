import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GoogleSignInUseCase implements UseCaseNoParams<User> {
  final AuthRepository repository;
  GoogleSignInUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call() {
    return repository.googleSignIn();
  }
}
