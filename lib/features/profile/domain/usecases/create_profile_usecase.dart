import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class CreateProfileParams {
  final String name;
  final String? profileImageUrl;
  final String? dob;

  const CreateProfileParams({
    required this.name,
    this.profileImageUrl,
    this.dob,
  });
}

class CreateProfileUseCase implements UseCase<Profile, CreateProfileParams> {
  final ProfileRepository repository;
  CreateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Profile>> call(CreateProfileParams params) {
    return repository.createProfile(params.name, params.profileImageUrl, params.dob);
  }
}
