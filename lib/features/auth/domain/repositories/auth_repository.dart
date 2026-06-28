import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> register(String email, String password);
  Future<Either<Failure, void>> verifyOtp(String email, String otp);
  Future<Either<Failure, void>> resendOtp(String email);
  Future<Either<Failure, void>> requestPasswordReset(String email);
  Future<Either<Failure, void>> resetPassword(String email, String otp, String newPassword);
  Future<Either<Failure, User>> googleSignIn();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> checkAuthStatus();
}
