import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileParams {
  final String name;
  final String? profileImageUrl;
  final String? dob;

  const UpdateProfileParams({
    required this.name,
    this.profileImageUrl,
    this.dob,
  });
}

class UpdateProfileUseCase implements UseCase<Profile, UpdateProfileParams> {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Profile>> call(UpdateProfileParams params) {
    return repository.updateProfile(params.name, params.profileImageUrl, params.dob);
  }
}
