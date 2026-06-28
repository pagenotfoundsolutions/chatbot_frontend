import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_api_client.dart';
import '../models/request/create_profile_request.dart';
import '../models/request/update_profile_request.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApiClient apiClient;

  ProfileRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    try {
      final response = await apiClient.getProfile();
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(const ServerFailure('Profile not found'));
      }
      return Left(ServerFailure(e.message ?? 'Failed to get profile'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Profile>> createProfile(String name, String? profileImageUrl, String? dob) async {
    try {
      final request = CreateProfileRequest(
        name: name,
        profileImageUrl: profileImageUrl,
        dob: dob,
      );
      final response = await apiClient.createProfile(request);
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to create profile'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile(String name, String? profileImageUrl, String? dob) async {
    try {
      final request = UpdateProfileRequest(
        name: name,
        profileImageUrl: profileImageUrl,
        dob: dob,
      );
      final response = await apiClient.updateProfile(request);
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update profile'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
