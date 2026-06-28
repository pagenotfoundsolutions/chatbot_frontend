import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/resp.dart';
import '../models/ai_provider_response.dart';

part 'ai_models_api_client.g.dart';

@RestApi()
abstract class AiModelsApiClient {
  factory AiModelsApiClient(Dio dio, {String baseUrl}) = _AiModelsApiClient;

  @GET(ApiConstants.getAiProvidersWithModels)
  Future<Resp<List<AIProviderResponse>>> getProvidersWithModels();
}
