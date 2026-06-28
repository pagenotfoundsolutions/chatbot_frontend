import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ResendOtpUseCase implements UseCase<void, String> {
  final AuthRepository repository;
  ResendOtpUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String email) {
    return repository.resendOtp(email);
  }
}
