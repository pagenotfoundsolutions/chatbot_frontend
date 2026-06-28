import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';

import '../repositories/auth_repository.dart';

class VerifyOtpParams {
  final String email;
  final String otp;
  const VerifyOtpParams({required this.email, required this.otp});
}

class VerifyOtpUseCase implements UseCase<void, VerifyOtpParams> {
  final AuthRepository repository;
  VerifyOtpUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(VerifyOtpParams params) {
    return repository.verifyOtp(params.email, params.otp);
  }
}
