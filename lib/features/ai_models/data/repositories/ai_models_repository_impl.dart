import 'package:dartz/dartz.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../datasources/ai_models_api_client.dart';
import '../../domain/entities/ai_provider.dart';
import '../../domain/repositories/ai_models_repository.dart';
import '../mappers/ai_provider_mapper.dart';

class AiModelsRepositoryImpl implements AiModelsRepository {
  final AiModelsApiClient apiClient;

  AiModelsRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<AIProvider>>> getProvidersWithModels() async {
    final result = await safeApiCall(() => apiClient.getProvidersWithModels());
    return result.fold(
      (failure) => Left(failure),
      (response) {
        if (response.success && response.data != null) {
          return Right(response.data!.map((e) => e.toDomain()).toList());
        }
        return Left(ServerFailure(response.message));
      },
    );
  }
}
