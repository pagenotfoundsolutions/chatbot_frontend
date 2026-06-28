import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_providers_event.freezed.dart';

@freezed
abstract class AiProvidersEvent with _$AiProvidersEvent {
  const factory AiProvidersEvent.fetchRequested() = FetchAiProvidersRequested;
  const factory AiProvidersEvent.modelSelected({
    required String providerId,
    required String modelId,
    @Default(false) bool thinkingEnabled,
  }) = ModelSelectedAiProvidersEvent;
}
