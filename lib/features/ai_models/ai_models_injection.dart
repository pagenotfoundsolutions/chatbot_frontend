import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import 'data/datasources/ai_models_api_client.dart';
import 'data/repositories/ai_models_repository_impl.dart';
import 'domain/repositories/ai_models_repository.dart';
import 'domain/usecases/get_ai_providers.dart';
import 'presentation/bloc/ai_providers_bloc.dart';

final sl = GetIt.instance;

void initAiModels() {
  // Data sources
  if (!sl.isRegistered<AiModelsApiClient>()) {
    sl.registerLazySingleton<AiModelsApiClient>(() => AiModelsApiClient(sl<Dio>()));
  }

  // Repository
  if (!sl.isRegistered<AiModelsRepository>()) {
    sl.registerLazySingleton<AiModelsRepository>(
      () => AiModelsRepositoryImpl(apiClient: sl()),
    );
  }

  // Use cases
  if (!sl.isRegistered<GetAiProvidersUseCase>()) {
    sl.registerLazySingleton(() => GetAiProvidersUseCase(sl()));
  }

  // BLoC
  if (!sl.isRegistered<AiProvidersBloc>()) {
    sl.registerLazySingleton(
      () => AiProvidersBloc(
        getAiProvidersUseCase: sl(),
      ),
    );
  }
}
