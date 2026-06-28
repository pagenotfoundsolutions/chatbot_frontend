import 'package:bloc/bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_ai_providers.dart';
import 'ai_providers_event.dart';
import 'ai_providers_state.dart';
import '../../domain/entities/model_capability.dart';

class AiProvidersBloc extends Bloc<AiProvidersEvent, AiProvidersState> {
  final GetAiProvidersUseCase getAiProvidersUseCase;

  AiProvidersBloc({required this.getAiProvidersUseCase}) : super(const AiProvidersState()) {
    on<FetchAiProvidersRequested>(_onFetchRequested);
    on<ModelSelectedAiProvidersEvent>(_onModelSelected);
  }

  void _onModelSelected(
    ModelSelectedAiProvidersEvent event,
    Emitter<AiProvidersState> emit,
  ) {
    emit(state.copyWith(
      selectedProviderId: event.providerId,
      selectedModelId: event.modelId,
      thinkingEnabled: event.thinkingEnabled,
    ));
  }

  Future<void> _onFetchRequested(
    FetchAiProvidersRequested event,
    Emitter<AiProvidersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await getAiProvidersUseCase(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (providers) {
        String? defaultProviderId = state.selectedProviderId;
        String? defaultModelId = state.selectedModelId;
        bool defaultThinking = state.thinkingEnabled;

        if (providers.isNotEmpty && (defaultProviderId == null || defaultModelId == null)) {
          defaultProviderId = providers.first.id;
          if (providers.first.models.isNotEmpty) {
            defaultModelId = providers.first.models.first.id;
            defaultThinking = providers.first.models.first.capabilities.contains(ModelCapability.reasoning);
          }
        }

        emit(state.copyWith(
          isLoading: false, 
          providers: providers,
          selectedProviderId: defaultProviderId,
          selectedModelId: defaultModelId,
          thinkingEnabled: defaultThinking,
        ));
      },
    );
  }
}
