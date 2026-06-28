import 'package:freezed_annotation/freezed_annotation.dart';
import 'model_capability.dart';

part 'ai_model.freezed.dart';

@freezed
abstract class AIModel with _$AIModel {
  const factory AIModel({
    @Default('') String id,
    @Default('') String providerId,
    @Default('') String modelKey,
    @Default('') String displayName,
    String? description,
    @Default(false) bool isActive,
    @Default([]) List<ModelCapability> capabilities,
  }) = _AIModel;
}
