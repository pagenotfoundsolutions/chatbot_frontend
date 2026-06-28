import 'package:freezed_annotation/freezed_annotation.dart';
import 'ai_model_response.dart';

part 'ai_provider_response.freezed.dart';
part 'ai_provider_response.g.dart';

@freezed
abstract class AIProviderResponse with _$AIProviderResponse {
  const factory AIProviderResponse({
    @Default('') String id,
    @Default('') String name,
    @JsonKey(name: 'display_name') @Default('') String displayName,
    String? description,
    @Default([]) List<AIModelResponse> models,
  }) = _AIProviderResponse;

  factory AIProviderResponse.fromJson(Map<String, dynamic> json) =>
      _$AIProviderResponseFromJson(json);
}
