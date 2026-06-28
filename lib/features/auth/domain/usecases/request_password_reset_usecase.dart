import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class RequestPasswordResetUseCase implements UseCase<void, String> {
  final AuthRepository repository;

  RequestPasswordResetUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String email) async {
    return await repository.requestPasswordReset(email);
  }
}
