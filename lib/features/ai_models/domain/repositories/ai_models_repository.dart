import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/ai_provider.dart';

abstract class AiModelsRepository {
  Future<Either<Failure, List<AIProvider>>> getProvidersWithModels();
}
