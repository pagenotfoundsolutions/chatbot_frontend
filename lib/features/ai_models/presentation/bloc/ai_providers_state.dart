import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/ai_provider.dart';

part 'ai_providers_state.freezed.dart';

@freezed
abstract class AiProvidersState with _$AiProvidersState {
  const factory AiProvidersState({
    @Default(false) bool isLoading,
    @Default([]) List<AIProvider> providers,
    String? selectedProviderId,
    String? selectedModelId,
    @Default(false) bool thinkingEnabled,
    String? error,
  }) = _AiProvidersState;
}
