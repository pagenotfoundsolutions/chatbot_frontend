import '../../domain/entities/ai_model.dart';
import '../../domain/entities/ai_provider.dart';
import '../models/ai_model_response.dart';
import '../models/ai_provider_response.dart';

extension AIModelResponseMapper on AIModelResponse {
  AIModel toDomain() {
    return AIModel(
      id: id,
      providerId: providerId,
      modelKey: modelKey,
      displayName: displayName,
      description: description,
      isActive: isActive,
      capabilities: capabilities,
    );
  }
}

extension AIProviderResponseMapper on AIProviderResponse {
  AIProvider toDomain() {
    return AIProvider(
      id: id,
      name: name,
      displayName: displayName,
      description: description,
      models: models.map((m) => m.toDomain()).toList(),
    );
  }
}
