import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile();
  Future<Either<Failure, Profile>> createProfile(String name, String? profileImageUrl, String? dob);
  Future<Either<Failure, Profile>> updateProfile(String name, String? profileImageUrl, String? dob);
}
