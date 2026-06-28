import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/model_capability.dart';

part 'ai_model_response.freezed.dart';
part 'ai_model_response.g.dart';

@freezed
abstract class AIModelResponse with _$AIModelResponse {
  const factory AIModelResponse({
    @Default('') String id,
    @JsonKey(name: 'provider_id') @Default('') String providerId,
    @JsonKey(name: 'model_key') @Default('') String modelKey,
    @JsonKey(name: 'display_name') @Default('') String displayName,
    String? description,
    @JsonKey(name: 'is_active') @Default(false) bool isActive,
    @JsonKey(name: 'capabilities') @Default([]) List<ModelCapability> capabilities,
  }) = _AIModelResponse;

  factory AIModelResponse.fromJson(Map<String, dynamic> json) =>
      _$AIModelResponseFromJson(json);
}
