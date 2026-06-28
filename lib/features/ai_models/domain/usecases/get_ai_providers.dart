import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/ai_provider.dart';
import '../repositories/ai_models_repository.dart';

class GetAiProvidersUseCase implements UseCase<List<AIProvider>, NoParams> {
  final AiModelsRepository repository;

  GetAiProvidersUseCase(this.repository);

  @override
  Future<Either<Failure, List<AIProvider>>> call(NoParams params) async {
    return await repository.getProvidersWithModels();
  }
}
