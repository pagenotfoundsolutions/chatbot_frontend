import 'package:dartz/dartz.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_api_client.dart';
import '../mappers/profile_mapper.dart';
import '../models/request/create_profile_request.dart';
import '../models/request/update_profile_request.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApiClient apiClient;

  ProfileRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    final result = await safeApiCall(() => apiClient.getProfile());
    return result.fold(
      (failure) => Left(failure),
      (response) {
        if (response.success && response.data != null) {
          return Right(response.data!.toEntity());
        }
        return Left(ServerFailure(response.message));
      },
    );
  }

  @override
  Future<Either<Failure, Profile>> createProfile(String name, String? profileImageUrl, String? dob) async {
    final request = CreateProfileRequest(
      name: name,
      profileImageUrl: profileImageUrl,
      dob: dob,
    );
    final result = await safeApiCall(() => apiClient.createProfile(request));
    return result.fold(
      (failure) => Left(failure),
      (response) {
        if (response.success && response.data != null) {
          return Right(response.data!.toEntity());
        }
        return Left(ServerFailure(response.message));
      },
    );
  }

  @override
  Future<Either<Failure, Profile>> updateProfile(String name, String? profileImageUrl, String? dob) async {
    final request = UpdateProfileRequest(
      name: name,
      profileImageUrl: profileImageUrl,
      dob: dob,
    );
    final result = await safeApiCall(() => apiClient.updateProfile(request));
    return result.fold(
      (failure) => Left(failure),
      (response) {
        if (response.success && response.data != null) {
          return Right(response.data!.toEntity());
        }
        return Left(ServerFailure(response.message));
      },
    );
  }
}
